import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("error.invalid_url", comment: "Invalid URL")
        case .noData:
            return NSLocalizedString("error.no_data", comment: "No data received")
        case .decodingError(let error):
            return String(format: NSLocalizedString("error.decoding", comment: "Decoding error: %@"), error.localizedDescription)
        case .httpError(let code):
            return String(format: NSLocalizedString("error.http", comment: "HTTP error: %d"), code)
        case .networkError(let error):
            return error.localizedDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return NSLocalizedString("error.recovery.network", comment: "Check your internet connection")
        case .httpError(429):
            return NSLocalizedString("error.recovery.rate_limit", comment: "Too many requests. Please try again later")
        default:
            return NSLocalizedString("error.recovery.default", comment: "Please try again")
        }
    }
}

protocol NetworkService: AnyObject {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func post<T: Decodable, B: Encodable>(_ endpoint: Endpoint, body: B) async throws -> T
}

final class NetworkServiceImpl: NetworkService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            if error is NetworkError {
                throw error
            }
            throw NetworkError.networkError(error)
        }
    }
    
    func post<T: Decodable, B: Encodable>(_ endpoint: Endpoint, body: B) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            if error is NetworkError {
                throw error
            }
            throw NetworkError.networkError(error)
        }
    }
}
