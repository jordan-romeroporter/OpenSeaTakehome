import SwiftUI

@main
struct PortfolioApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
                .environmentObject(appCoordinator)
        }
    }
}
