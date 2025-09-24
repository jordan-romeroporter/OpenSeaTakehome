import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("portfolio.empty_state.title", comment: "No Assets Found"))
                .font(.headline)
            
            Text(NSLocalizedString("portfolio.empty_state.message", comment: "This wallet doesn't have any tokens or NFTs"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
