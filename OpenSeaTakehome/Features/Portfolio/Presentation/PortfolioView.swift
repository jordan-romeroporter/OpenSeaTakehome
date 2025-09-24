import SwiftUI

struct PortfolioView: View {
    @StateObject private var viewModel: PortfolioViewModel
    @FocusState private var isAddressFocused: Bool

    init(viewModel: PortfolioViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                addressInputSection

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel(
                            NSLocalizedString(
                                "accessibility.loading",
                                comment: "Loading portfolio"
                            )
                        )
                } else {
                    portfolioList
                }
            }
            .navigationTitle(
                NSLocalizedString("portfolio.title", comment: "Portfolio")
            )
            .alert(
                NSLocalizedString("error.title", comment: "Error"),
                isPresented: $viewModel.showError,
                presenting: viewModel.error
            ) { _ in
                Button(NSLocalizedString("button.ok", comment: "OK")) {}
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }

    private var addressInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Network Selector
            HStack {
                Text(
                    NSLocalizedString(
                        "portfolio.network_label",
                        comment: "Network"
                    )
                )
                .font(.headline)
                .foregroundColor(.primary)

                Spacer()

                Menu {
                    ForEach(SupportedNetwork.allCases) { network in
                        Button(action: {
                            viewModel.selectedNetwork = network
                        }) {
                            Label(
                                network.displayName,
                                systemImage: network
                                    == viewModel.selectedNetwork
                                    ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedNetwork.chainIcon)
                        Text(viewModel.selectedNetwork.displayName)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .accessibilityLabel(
                    NSLocalizedString(
                        "accessibility.network_selector",
                        comment: "Network selector"
                    )
                )
            }

            // Wallet Address Input
            VStack(alignment: .leading, spacing: 8) {
                Text(
                    NSLocalizedString(
                        "portfolio.address_label",
                        comment: "Wallet Address"
                    )
                )
                .font(.headline)
                .foregroundColor(.primary)

                HStack {
                    TextField(
                        NSLocalizedString(
                            "portfolio.address_placeholder",
                            comment: "0x..."
                        ),
                        text: $viewModel.walletAddress
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isAddressFocused)
                    .accessibilityLabel(
                        NSLocalizedString(
                            "accessibility.wallet_input",
                            comment: "Wallet address input"
                        )
                    )

                    Button(action: {
                        isAddressFocused = false
                        Task {
                            await viewModel.loadPortfolio()
                        }
                    }) {
                        Text(NSLocalizedString("button.load", comment: "Load"))
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.isValidAddress || viewModel.isLoading)
                }

                if !viewModel.walletAddress.isEmpty && !viewModel.isValidAddress
                {
                    Text(
                        NSLocalizedString(
                            "portfolio.invalid_address",
                            comment: "Please enter a valid Ethereum address"
                        )
                    )
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var portfolioList: some View {
        List {
            if !viewModel.tokens.isEmpty {
                Section(
                    NSLocalizedString(
                        "portfolio.tokens_section",
                        comment: "Tokens"
                    )
                ) {
                    ForEach(viewModel.tokens) { token in
                        TokenRow(token: token)
                    }
                }
            }

            if !viewModel.nftContracts.isEmpty {
                Section(
                    NSLocalizedString(
                        "portfolio.nft_section",
                        comment: "NFT Collections"
                    )
                ) {
                    ForEach(viewModel.nftContracts) { contract in
                        NFTContractRow(contract: contract)
                    }
                }
            }

            if viewModel.tokens.isEmpty && viewModel.nftContracts.isEmpty
                && !viewModel.walletAddress.isEmpty && viewModel.isValidAddress
            {
                EmptyStateView()
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
