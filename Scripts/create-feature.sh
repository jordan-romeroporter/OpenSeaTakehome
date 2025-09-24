#!/bin/bash

# Feature factory for rapid development

set -euo pipefail

FEATURE_NAME=${1-}
if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: ./create-feature.sh <FeatureName>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FEATURES_ROOT="$PROJECT_DIR/OpenSeaTakehome/Features"
TESTS_ROOT="$PROJECT_DIR/OpenSeaTakehomeTests"

FEATURE_DIR="$FEATURES_ROOT/$FEATURE_NAME"

if [ -d "$FEATURE_DIR" ]; then
    echo "Feature $FEATURE_NAME already exists at $FEATURE_DIR"
    exit 1
fi

echo "🚀 Creating feature: $FEATURE_NAME"

FOLDER_NAME=$(echo "$FEATURE_NAME" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]')

mkdir -p "$FEATURE_DIR/Domain" \
         "$FEATURE_DIR/Data" \
         "$FEATURE_DIR/Presentation" \
         "$FEATURE_DIR/Presentation/Components" \
         "$FEATURE_DIR/Coordinator"

cat <<DOMAIN > "$FEATURE_DIR/Domain/${FEATURE_NAME}Models.swift"
import Foundation

// MARK: - ${FEATURE_NAME} Domain Models
struct ${FEATURE_NAME}Model: Identifiable, Codable, Equatable {
    let id: UUID
    // TODO: Add properties
}

// MARK: - Use Cases
protocol ${FEATURE_NAME}UseCase {
    func execute() async throws -> ${FEATURE_NAME}Model
}
DOMAIN

cat <<DATA > "$FEATURE_DIR/Data/${FEATURE_NAME}Service.swift"
import Foundation

protocol ${FEATURE_NAME}Service: AnyObject {
    func fetch() async throws -> ${FEATURE_NAME}Model
}

final class ${FEATURE_NAME}ServiceImpl: ${FEATURE_NAME}Service {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetch() async throws -> ${FEATURE_NAME}Model {
        // TODO: Implement fetch logic
        fatalError("Implement fetch")
    }
}
DATA

cat <<VIEWMODEL > "$FEATURE_DIR/Presentation/${FEATURE_NAME}ViewModel.swift"
import Combine
import Foundation

@MainActor
final class ${FEATURE_NAME}ViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case loaded
        case error(Error)
    }
    
    @Published var state: ViewState = .idle
    @Published var model: ${FEATURE_NAME}Model?
    
    private let service: ${FEATURE_NAME}Service
    private var cancellables = Set<AnyCancellable>()
    
    init(service: ${FEATURE_NAME}Service) {
        self.service = service
    }
    
    func load() async {
        state = .loading
        do {
            model = try await service.fetch()
            state = .loaded
        } catch {
            state = .error(error)
        }
    }
}
VIEWMODEL

cat <<VIEW > "$FEATURE_DIR/Presentation/${FEATURE_NAME}View.swift"
import SwiftUI

struct ${FEATURE_NAME}View: View {
    @StateObject private var viewModel: ${FEATURE_NAME}ViewModel
    
    init(viewModel: ${FEATURE_NAME}ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear.onAppear {
                    Task { await viewModel.load() }
                }
            case .loading:
                ProgressView()
                    .accessibilityLabel(NSLocalizedString("accessibility.loading", comment: "Loading"))
            case .loaded:
                content
            case .error(let error):
                ErrorView(error: error) {
                    Task { await viewModel.load() }
                }
            }
        }
        .navigationTitle(NSLocalizedString("${FOLDER_NAME}.title", comment: "${FEATURE_NAME}"))
    }
    
    private var content: some View {
        Text("${FEATURE_NAME} Content")
    }
}
VIEW

cat <<COORDINATOR > "$FEATURE_DIR/Coordinator/${FEATURE_NAME}Coordinator.swift"
import SwiftUI

struct ${FEATURE_NAME}Coordinator {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    @MainActor
    func start() -> some View {
        let viewModel = ${FEATURE_NAME}ViewModel(
            service: container.resolve(${FEATURE_NAME}Service.self)
        )
        return ${FEATURE_NAME}View(viewModel: viewModel)
    }
}
COORDINATOR

TESTS_DIR="$TESTS_ROOT/${FEATURE_NAME}Tests"
mkdir -p "$TESTS_DIR"

cat <<TEST > "$TESTS_DIR/${FEATURE_NAME}ViewModelTests.swift"
import XCTest
@testable import OpenSeaTakehome

@MainActor
final class ${FEATURE_NAME}ViewModelTests: XCTestCase {
    var sut: ${FEATURE_NAME}ViewModel!
    var mockService: Mock${FEATURE_NAME}Service!
    
    override func setUp() {
        super.setUp()
        mockService = Mock${FEATURE_NAME}Service()
        sut = ${FEATURE_NAME}ViewModel(service: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    func test_load_success() async {
        mockService.mockResult = .success(${FEATURE_NAME}Model(id: UUID()))
        await sut.load()
        XCTAssertNotNil(sut.model)
    }
}

final class Mock${FEATURE_NAME}Service: ${FEATURE_NAME}Service {
    var mockResult: Result<${FEATURE_NAME}Model, Error>?
    
    func fetch() async throws -> ${FEATURE_NAME}Model {
        switch mockResult {
        case .success(let model):
            return model
        case .failure(let error):
            throw error
        case .none:
            throw NSError(domain: "Test", code: 0)
        }
    }
}
TEST

echo "✅ Feature $FEATURE_NAME created successfully!"
echo "📝 Next steps:"
echo "  1. Add to DependencyContainer"
echo "  2. Update Localizable.strings"
echo "  3. Implement service logic"
echo "  4. Add UI tests if needed"
