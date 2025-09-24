import SwiftUI

struct PortfolioCoordinator {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    @MainActor
    func start() -> some View {
        let viewModel = PortfolioViewModel(
            portfolioService: container.resolve(PortfolioService.self),
            validationService: container.resolve(ValidationService.self)
        )
        return PortfolioView(viewModel: viewModel)
    }
}
