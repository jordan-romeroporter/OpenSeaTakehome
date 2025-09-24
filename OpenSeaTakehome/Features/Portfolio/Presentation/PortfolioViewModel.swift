import Combine
import Foundation

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published var walletAddress: String = ""
    @Published var selectedNetwork: SupportedNetwork = .ethereumMainnet
    @Published var tokens: [Token] = []
    @Published var nftContracts: [NFTContract] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showError = false

    private let portfolioService: PortfolioService
    private let validationService: ValidationService
    private var cancellables = Set<AnyCancellable>()

    init(
        portfolioService: PortfolioService,
        validationService: ValidationService
    ) {
        self.portfolioService = portfolioService
        self.validationService = validationService
        setupBindings()
    }

    private func setupBindings() {
        $error
            .map { $0 != nil }
            .assign(to: &$showError)
    }

    var isValidAddress: Bool {
        validationService.isValidWalletAddress(walletAddress)
    }

    func loadPortfolio() async {
        guard isValidAddress else {
            error = ValidationError.invalidAddress
            return
        }

        isLoading = true
        error = nil

        // For now, use only the selected network
        // Future: Could allow multiple network selection
        let networks = [selectedNetwork]

        async let tokensTask = portfolioService.fetchTokens(
            for: walletAddress,
            networks: networks
        )
        async let nftsTask = portfolioService.fetchNFTContracts(
            for: walletAddress,
            networks: networks
        )

        do {
            let (fetchedTokens, fetchedNFTs) = try await (tokensTask, nftsTask)
            tokens = fetchedTokens
            nftContracts = fetchedNFTs
        } catch {
            self.error = error
        }

        isLoading = false
    }
}

enum ValidationError: LocalizedError {
    case invalidAddress

    var errorDescription: String? {
        NSLocalizedString(
            "error.invalid_address",
            comment: "Invalid wallet address"
        )
    }

    var recoverySuggestion: String? {
        NSLocalizedString(
            "error.invalid_address.recovery",
            comment: "Please enter a valid Ethereum address (0x...)"
        )
    }
}
