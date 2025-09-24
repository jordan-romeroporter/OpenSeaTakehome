import SwiftUI

struct NFTContractRow: View {
    let contract: NFTContract

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(contract.displayName)
                .font(.headline)
                .lineLimit(1)
                .accessibilityLabel(
                    String(
                        format: NSLocalizedString(
                            "accessibility.nft_collection",
                            comment: "NFT Collection: %@"
                        ),
                        contract.displayName
                    )
                )

            HStack {
                if let symbol = contract.symbol {
                    Text(symbol)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let balance = contract.totalBalance {
                    Text("\(balance) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
