import Foundation

enum SupportedNetwork: String, CaseIterable, Identifiable {
    // Ethereum
    case ethereumMainnet = "eth-mainnet"
    case ethereumSepolia = "eth-sepolia"
    
    // Polygon
    case polygonMainnet = "polygon-mainnet"
    case polygonAmoy = "polygon-amoy"
    
    // Optimism
    case optimismMainnet = "opt-mainnet"
    case optimismSepolia = "opt-sepolia"
    
    // Arbitrum
    case arbitrumMainnet = "arb-mainnet"
    case arbitrumSepolia = "arb-sepolia"
    
    // Base
    case baseMainnet = "base-mainnet"
    case baseSepolia = "base-sepolia"
    
    // Solana
    case solanaMainnet = "solana-mainnet"
    case solanaDevnet = "solana-devnet"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .ethereumMainnet: return "Ethereum"
        case .ethereumSepolia: return "Ethereum Sepolia"
        case .polygonMainnet: return "Polygon"
        case .polygonAmoy: return "Polygon Amoy"
        case .optimismMainnet: return "Optimism"
        case .optimismSepolia: return "Optimism Sepolia"
        case .arbitrumMainnet: return "Arbitrum"
        case .arbitrumSepolia: return "Arbitrum Sepolia"
        case .baseMainnet: return "Base"
        case .baseSepolia: return "Base Sepolia"
        case .solanaMainnet: return "Solana"
        case .solanaDevnet: return "Solana Devnet"
        }
    }
    
    var chainIcon: String {
        switch self {
        case .ethereumMainnet, .ethereumSepolia: return "🔷"
        case .polygonMainnet, .polygonAmoy: return "🟣"
        case .optimismMainnet, .optimismSepolia: return "🔴"
        case .arbitrumMainnet, .arbitrumSepolia: return "🔵"
        case .baseMainnet, .baseSepolia: return "🔷"
        case .solanaMainnet, .solanaDevnet: return "☀️"
        }
    }
    
    var isTestnet: Bool {
        switch self {
        case .ethereumSepolia, .polygonAmoy, .optimismSepolia,
             .arbitrumSepolia, .baseSepolia, .solanaDevnet:
            return true
        default:
            return false
        }
    }
}
