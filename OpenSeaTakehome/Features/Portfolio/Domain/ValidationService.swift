import Foundation

protocol ValidationService {
    func isValidWalletAddress(_ address: String) -> Bool
}

final class ValidationServiceImpl: ValidationService {
    func isValidWalletAddress(_ address: String) -> Bool {
        // Ethereum address validation
        let pattern = "^0x[a-fA-F0-9]{40}$"
        return address.range(of: pattern, options: .regularExpression) != nil
    }
}
