import Foundation

@MainActor
final class DependencyContainer {
    private var services: [String: Any] = [:]

    func register() {
        // Register core services
        register(NetworkService.self, NetworkServiceImpl())
        register(
            PortfolioService.self,
            PortfolioServiceImpl(networkService: resolve(NetworkService.self))
        )
        register(ValidationService.self, ValidationServiceImpl())
    }

    private func register<T>(_ type: T.Type, _ service: T) {
        let key = String(describing: type)
        services[key] = service
    }

    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("❌ Service \(key) not registered")
        }
        return service
    }
}
