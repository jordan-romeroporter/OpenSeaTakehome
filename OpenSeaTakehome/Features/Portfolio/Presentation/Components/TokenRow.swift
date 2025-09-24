import SwiftUI

struct TokenRow: View {
    let token: Token

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(token.displayName)
                    .font(.headline)
                    .accessibilityLabel(
                        String(
                            format: NSLocalizedString(
                                "accessibility.token_name",
                                comment: "Token: %@"
                            ),
                            token.displayName
                        )
                    )

                if let symbol = token.symbol {
                    Text(symbol)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let balance = token.balance {
                    Text(formatBalance(balance))
                        .font(.body)
                        .accessibilityLabel(
                            String(
                                format: NSLocalizedString(
                                    "accessibility.balance",
                                    comment: "Balance: %@"
                                ),
                                formatBalance(balance)
                            )
                        )
                }

                if let usdValue = token.balanceUsd {
                    Text(formatUSD(usdValue))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 0

        return formatter.string(from: NSNumber(value: balance))
            ?? String(balance)
    }

    private func formatUSD(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
