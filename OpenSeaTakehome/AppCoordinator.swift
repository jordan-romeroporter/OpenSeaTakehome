import Combine
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    private let container: DependencyContainer

    init() {
        self.container = DependencyContainer()
        container.register()
    }

    func start() -> some View {
        PortfolioCoordinator(container: container).start()
    }
}
