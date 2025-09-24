import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

    var url: URL? {
        var components = URLComponents(
            string: Environment.current.baseURL + path
        )
        components?.queryItems = queryItems
        return components?.url
    }
}
