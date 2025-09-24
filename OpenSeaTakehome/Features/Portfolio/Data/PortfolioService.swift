import Foundation

protocol PortfolioService: AnyObject {
    func fetchTokens(for address: String, networks: [SupportedNetwork]) async throws -> [Token]
    func fetchNFTContracts(for address: String, networks: [SupportedNetwork]) async throws -> [NFTContract]
}

final class PortfolioServiceImpl: PortfolioService {
    private let networkService: NetworkService
    private let apiKey = Environment.current.alchemyAPIKey
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchTokens(for address: String, networks: [SupportedNetwork]) async throws -> [Token] {
        let endpoint = Endpoint(
            path: "/data/v1/\(apiKey)/assets/tokens/by-address",
            queryItems: []
        )

        let requestBody = TokensRequest(address: address, networks: networks)
        let response: TokensResponse = try await networkService.post(endpoint, body: requestBody)
        
        return response.toDomainTokens()
    }
    
    func fetchNFTContracts(for address: String, networks: [SupportedNetwork]) async throws -> [NFTContract] {
        let endpoint = Endpoint(
            path: "/data/v1/\(apiKey)/assets/nfts/contracts/by-address",
            queryItems: []
        )
        
        let requestBody = NFTContractsRequest(address: address, networks: networks)
        let response: NFTContractsResponse = try await networkService.post(endpoint, body: requestBody)
        
        return response.toDomainContracts()
    }
}
