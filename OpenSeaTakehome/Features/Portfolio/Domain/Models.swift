import Foundation

// MARK: - Request Models
struct TokensRequest: Encodable {
    let addresses: [AddressNetworkPair]
    let withMetadata: Bool = true
    let withPrices: Bool = true
    let includeNativeTokens: Bool = true
    let includeErc20Tokens: Bool = true
    let pageKey: String?
    
    struct AddressNetworkPair: Encodable {
        let address: String
        let networks: [String]
    }
    
    init(address: String, networks: [SupportedNetwork], pageKey: String? = nil) {
        self.addresses = [AddressNetworkPair(
            address: address,
            networks: networks.map { $0.rawValue }
        )]
        self.pageKey = pageKey
    }
}

struct NFTContractsRequest: Encodable {
    let addresses: [AddressNetworkPair]
    let withMetadata: Bool = true
    let pageKey: String?
    let pageSize: Int = 100
    
    struct AddressNetworkPair: Encodable {
        let address: String
        let networks: [String]
    }
    
    init(address: String, networks: [SupportedNetwork], pageKey: String? = nil) {
        self.addresses = [AddressNetworkPair(
            address: address,
            networks: networks.map { $0.rawValue }
        )]
        self.pageKey = pageKey
    }
}

// MARK: - Response Models
struct TokensResponse: Decodable {
    let data: TokensData

    struct TokensData: Decodable {
        let tokens: [TokenDTO]
        let pageKey: String?
    }

    struct TokenDTO: Decodable {
        let address: String?
        let network: String?
        let tokenAddress: String?
        let tokenBalance: String?
        let tokenMetadata: TokenMetadataDTO?
        let tokenPrices: [TokenPriceDTO]?
        let error: String?

        struct TokenMetadataDTO: Decodable {
            let symbol: String?
            let decimals: Int?
            let name: String?
            let logo: String?
        }

        struct TokenPriceDTO: Decodable {
            let currency: String
            let value: TokenPriceValue

            enum TokenPriceValue: Decodable {
                case string(String)
                case number(Double)

                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let stringValue = try? container.decode(String.self) {
                        self = .string(stringValue)
                        return
                    }
                    if let doubleValue = try? container.decode(Double.self) {
                        self = .number(doubleValue)
                        return
                    }
                    throw DecodingError.typeMismatch(
                        String.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Unsupported token price value type"
                        )
                    )
                }

                var doubleValue: Double? {
                    switch self {
                    case .string(let string):
                        return Double(string)
                    case .number(let double):
                        return double
                    }
                }
            }
        }
    }
}

extension TokensResponse {
    func toDomainTokens() -> [Token] {
        data.tokens
            .filter { $0.error == nil }
            .map { $0.toDomainToken() }
    }
}

private extension TokensResponse.TokenDTO {
    func toDomainToken() -> Token {
        let rawBalance = Self.hexToDecimalString(tokenBalance)
        let resolvedDecimals = tokenMetadata?.decimals ?? (tokenAddress == nil ? 18 : nil)
        let normalizedBalance = Self.normalizedBalance(from: rawBalance, decimals: resolvedDecimals)

        let usdPrice = (tokenPrices ?? [])
            .first { $0.currency.lowercased() == "usd" }
            .flatMap { $0.value.doubleValue }

        let balanceUsd = normalizedBalance.flatMap { balance in
            usdPrice.map { balance * $0 }
        }

        return Token(
            contractAddress: tokenAddress,
            name: tokenMetadata?.name,
            symbol: tokenMetadata?.symbol,
            decimals: resolvedDecimals,
            logo: tokenMetadata?.logo,
            balance: normalizedBalance,
            balanceRawInteger: rawBalance,
            balanceUsd: balanceUsd,
            price: usdPrice,
            priceChange: nil,
            isSpam: nil
        )
    }

    static func normalizedBalance(from decimalString: String?, decimals: Int?) -> Double? {
        guard let decimalString, !decimalString.isEmpty else { return nil }

        guard let baseValue = doubleFromDecimalString(decimalString) else {
            return nil
        }

        guard let decimals, decimals > 0 else {
            return baseValue
        }

        let divisor = pow(10.0, Double(decimals))
        return baseValue / divisor
    }

    static func doubleFromDecimalString(_ value: String) -> Double? {
        var result = 0.0
        for character in value {
            guard let digit = character.wholeNumberValue else { return nil }
            result = result * 10 + Double(digit)
        }
        return result
    }

    static func hexToDecimalString(_ hexString: String?) -> String? {
        guard var hex = hexString?.lowercased() else { return nil }
        if hex.hasPrefix("0x") {
            hex.removeFirst(2)
        }

        guard !hex.isEmpty else { return "0" }

        var decimal = "0"
        for character in hex {
            guard let value = character.hexDigitValue else { continue }
            decimal = multiplyDecimalString(decimal, by: 16)
            decimal = addDecimalString(decimal, value)
        }
        return decimal
    }

    static func multiplyDecimalString(_ number: String, by multiplier: Int) -> String {
        guard multiplier != 0 else { return "0" }

        var carry = 0
        var result: [Character] = []
        for character in number.reversed() {
            guard let digit = character.wholeNumberValue else { return "0" }
            let product = digit * multiplier + carry
            carry = product / 10
            let remainder = product % 10
            result.append(Character(String(remainder)))
        }

        while carry > 0 {
            result.append(Character(String(carry % 10)))
            carry /= 10
        }

        return String(result.reversed()).trimmingLeadingZeros()
    }

    static func addDecimalString(_ number: String, _ addend: Int) -> String {
        var carry = addend
        var result: [Character] = []
        for character in number.reversed() {
            guard let digit = character.wholeNumberValue else { return number }
            let sum = digit + carry
            carry = sum / 10
            let remainder = sum % 10
            result.append(Character(String(remainder)))
        }

        while carry > 0 {
            result.append(Character(String(carry % 10)))
            carry /= 10
        }

        return String(result.reversed()).trimmingLeadingZeros()
    }
}

private extension String {
    func trimmingLeadingZeros() -> String {
        let trimmed = drop { $0 == "0" }
        return trimmed.isEmpty ? "0" : String(trimmed)
    }
}

struct NFTContractsResponse: Decodable {
    let data: NFTContractsData

    struct NFTContractsData: Decodable {
        let contracts: [ContractDTO]
        let totalCount: Int?
        let pageKey: String?
    }

    struct ContractDTO: Decodable {
        let network: String?
        let address: String?
        let contract: ContractDetailsDTO?

        struct ContractDetailsDTO: Decodable {
            let address: String?
            let name: String?
            let symbol: String?
            let tokenType: String?
            let totalSupply: String?
            let totalBalance: String?
            let numDistinctTokensOwned: String?
            let contractDeployer: String?
            let deployedBlockNumber: Double?
            let openseaMetadata: OpenSeaDTO?
            let isSpam: SpamValue?
            let spamClassifications: [String]?
            let media: NFTMediaDTO?

            struct NFTMediaDTO: Decodable {
                let collectionBannerImageUrl: String?
                let collectionImageUrl: String?
            }

            struct OpenSeaDTO: Decodable {
                let collectionName: String?
                let description: String?
                let imageUrl: String?
                let bannerImageUrl: String?
                let floorPrice: Double?
                let twitterUsername: String?
                let discordUrl: String?
                let externalUrl: String?
                let safelistRequestStatus: String?
                let lastIngestedAt: String?
            }
            enum SpamValue: Decodable {
                case string(String)
                case bool(Bool)

                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let boolValue = try? container.decode(Bool.self) {
                        self = .bool(boolValue)
                        return
                    }
                    if let stringValue = try? container.decode(String.self) {
                        self = .string(stringValue)
                        return
                    }
                    throw DecodingError.typeMismatch(
                        String.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Unsupported isSpam value type"
                        )
                    )
                }

                var boolValue: Bool? {
                    switch self {
                    case .bool(let value):
                        return value
                    case .string(let string):
                        switch string.lowercased() {
                        case "true":
                            return true
                        case "false":
                            return false
                        default:
                            return nil
                        }
                    }
                }
            }
        }
    }
}

extension NFTContractsResponse {
    func toDomainContracts() -> [NFTContract] {
        data.contracts.compactMap { $0.toDomainContract() }
    }
}

private extension NFTContractsResponse.ContractDTO {
    func toDomainContract() -> NFTContract? {
        guard let details = contract,
              let contractAddress = details.address else {
            return nil
        }

        return NFTContract(
            contractAddress: contractAddress,
            name: details.name,
            symbol: details.symbol,
            tokenType: details.tokenType,
            totalSupply: details.totalSupply,
            totalBalance: Self.intValue(from: details.totalBalance),
            numDistinctTokensOwned: Self.intValue(from: details.numDistinctTokensOwned),
            contractDeployer: details.contractDeployer,
            deployedBlockNumber: details.deployedBlockNumber,
            isSpam: details.isSpam?.boolValue,
            spamClassifications: details.spamClassifications,
            media: details.media.map(NFTMedia.init(dto:)),
            opensea: details.openseaMetadata.map(OpenSeaMetadata.init(dto:))
        )
    }

    static func intValue(from string: String?) -> Int? {
        guard let string else { return nil }
        return Int(string)
    }
}

private extension NFTMedia {
    init(dto: NFTContractsResponse.ContractDTO.ContractDetailsDTO.NFTMediaDTO) {
        self.init(
            collectionBannerImageUrl: dto.collectionBannerImageUrl,
            collectionImageUrl: dto.collectionImageUrl
        )
    }
}

private extension OpenSeaMetadata {
    init(dto: NFTContractsResponse.ContractDTO.ContractDetailsDTO.OpenSeaDTO) {
        self.init(
            collectionName: dto.collectionName,
            description: dto.description,
            imageUrl: dto.imageUrl,
            bannerImageUrl: dto.bannerImageUrl,
            floorPrice: dto.floorPrice,
            twitterUsername: dto.twitterUsername,
            discordUrl: dto.discordUrl,
            externalUrl: dto.externalUrl,
            safelistRequestStatus: dto.safelistRequestStatus,
            lastIngestedAt: dto.lastIngestedAt
        )
    }
}

// MARK: - Domain Models
struct Token: Identifiable, Equatable {
    let id = UUID()
    let contractAddress: String?
    let name: String?
    let symbol: String?
    let decimals: Int?
    let logo: String?
    let balance: Double?
    let balanceRawInteger: String?
    let balanceUsd: Double?
    let price: Double?
    let priceChange: PriceChange?
    let isSpam: Bool?
    
    var displayName: String {
        name ?? symbol ?? "Unknown Token"
    }
    
    var isNativeToken: Bool {
        contractAddress == nil
    }
}

struct PriceChange: Codable, Equatable {
    let last24Hours: Double?
    let last7Days: Double?
    let last30Days: Double?
}

struct NFTContract: Identifiable, Codable, Equatable {
    let id = UUID()
    let contractAddress: String
    let name: String?
    let symbol: String?
    let tokenType: String?
    let totalSupply: String?
    let totalBalance: Int?
    let numDistinctTokensOwned: Int?
    let contractDeployer: String?
    let deployedBlockNumber: Double?
    let isSpam: Bool?
    let spamClassifications: [String]?
    let media: NFTMedia?
    let opensea: OpenSeaMetadata?
    
    private enum CodingKeys: String, CodingKey {
        case contractAddress, name, symbol, tokenType
        case totalSupply, totalBalance, numDistinctTokensOwned
        case contractDeployer, deployedBlockNumber
        case isSpam, spamClassifications
        case media, opensea
    }
    
    var displayName: String {
        name ?? contractAddress
    }
}

struct NFTMedia: Codable, Equatable {
    let collectionBannerImageUrl: String?
    let collectionImageUrl: String?
}

struct OpenSeaMetadata: Codable, Equatable {
    let collectionName: String?
    let description: String?
    let imageUrl: String?
    let bannerImageUrl: String?
    let floorPrice: Double?
    let twitterUsername: String?
    let discordUrl: String?
    let externalUrl: String?
    let safelistRequestStatus: String?
    let lastIngestedAt: String?
}
