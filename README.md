# Portfolio iOS App

Staff-level iOS architecture demonstration with developer velocity tools and scalable patterns.

## 🚀 Quick Start

1. **Clone repository**
   ```bash
   git clone https://github.com/jordan-romeroporter/OpenSeaTakehome.git
   cd OpenSeaTakehome
   ```
2. **Run automated setup**
   ```bash
   ./Scripts/setup.sh
   ```
3. **Configure API key**
   ```bash
   echo "ALCHEMY_API_KEY = your_key_here" > Config.xcconfig
   ```
4. **Open in Xcode**
   ```bash
   open OpenSeaTakehome.xcodeproj
   ```

## 🛠 Developer Tools Setup

### Prerequisites

- Xcode command-line tools
- SwiftLint (`brew install swiftlint`)
- Claude CLI (`pip install anthropic` or download from Anthropic) with a configured `ANTHROPIC_API_KEY`

### Install Command Aliases
Add these aliases to your shell for a better developer experience:

```bash
# Add to ~/.zshrc or ~/.bashrc
echo '
# Portfolio App Developer Tools
alias pf-commit="./Scripts/commit-ai.sh"
alias pf-feature="./Scripts/create-feature.sh"
alias pf-audit="./Scripts/accessibility-audit.sh"
alias pf-docs="./Scripts/generate-docs.sh"
alias pf-setup="./Scripts/setup.sh"

# Quick commands
alias pf-test="swift test"
alias pf-build="xcodebuild -scheme Portfolio build"
alias pf-clean="xcodebuild clean"
' >> ~/.zshrc

# Reload shell configuration
source ~/.zshrc
```

### One-Line Installation
```bash
curl -s https://raw.githubusercontent.com/jordan-romeroporter/OpenSeaTakehome/main/Scripts/install-aliases.sh | bash
```

## 📝 Command Reference

| Command | Description | Example |
| --- | --- | --- |
| `pf-commit` | AI-powered commit message generator | `pf-commit` |
| `pf-feature <Name>` | Generate complete feature module | `pf-feature Payment` |
| `pf-audit` | Run accessibility audit | `pf-audit` |
| `pf-docs` | Generate documentation | `pf-docs` |
| `pf-setup` | Initial project setup | `pf-setup` |
| `pf-test` | Run Swift tests | `pf-test` |
| `pf-build` | Build project | `pf-build` |
| `pf-clean` | Clean build folder | `pf-clean` |

> `pf-commit` uses the Claude CLI and requires a valid `ANTHROPIC_API_KEY`.

## 🏗 Architecture

**Clean Architecture + MVVM-C**

```
OpenSeaTakehome/
├── Configuration/          # Environment + secrets
├── Core/                   # Shared infrastructure (networking, DI)
├── DesignSystem/           # Reusable UI components
├── OpenSeaTakehome/        # App entry point + features
│   ├── PortfolioApp.swift
│   ├── AppCoordinator.swift
│   └── Features/
│       └── [Feature]/
│           ├── Domain/     # Business logic
│           ├── Data/       # Services & repositories
│           ├── Presentation/ # Views & ViewModels
│           └── Coordinator/  # Navigation
├── Scripts/                # Developer productivity scripts
└── Resources/              # Localized strings, assets, etc.
```

## 🧪 Testing Strategy

**Modern Swift Testing Framework**

```swift
@Test("User can load portfolio")
func loadPortfolio() async {
    await viewModel.loadPortfolio()
    #expect(viewModel.tokens.count > 0)
}
```

**Test Coverage Goals**
- Unit Tests: >80% coverage
- Integration Tests: API layer
- UI Tests: Critical user paths
- Accessibility Tests: 100% compliance

## 🔑 API Configuration

**Environment-Based Setup**
1. Development: Uses .xcconfig file
2. CI/CD: Environment variables
3. Production: Keychain storage

See `Documentation/API_KEY_SETUP.md` for detailed configuration.

## 📚 Documentation

- Architecture Decision Records
- Contributing Guidelines
- API Documentation
- Release Process

## 🎯 Features

**Current**
- ✅ Wallet address validation
- ✅ Token portfolio display
- ✅ NFT collection listing
- ✅ Comprehensive error handling
- ✅ Full accessibility support
- ✅ Localization ready

**Roadmap**
- 📱 Multi-wallet support
- 📊 Portfolio analytics
- 🔄 Real-time updates
- 💾 Offline mode
- 📈 Historical tracking

## 🤝 Contributing

**Creating a New Feature**

```bash
# Generate feature structure
pf-feature UserProfile

# Make changes
# ...

# Commit with AI
pf-commit

# Run tests
pf-test
```

**Code Review Checklist**
- [ ] Follows architecture patterns
- [ ] Includes tests (>70% coverage)
- [ ] Accessibility compliant
- [ ] Strings localized
- [ ] No hardcoded values
- [ ] Documentation updated

## 📊 Metrics

**Developer Velocity**
- Feature Cycle Time: 2-3 days
- PR Review Time: <4 hours
- Build Time: <2 minutes
- Test Execution: <30 seconds

**Code Quality**
- SwiftLint: Zero violations
- Test Coverage: >80%
- Crash Rate: <0.1%
- Performance: 60fps

## 🚦 CI/CD

GitHub Actions workflow:
1. Lint: SwiftLint validation
2. Test: Unit & UI tests
3. Audit: Accessibility check
4. Build: Debug & Release
5. Deploy: TestFlight (on main)

## 📱 Requirements

- iOS: 16.0+
- Xcode: 15.0+
- Swift: 5.9+
- macOS: 13.0+ (for development)

## 📄 License

MIT License

## 🙋‍♂️ Support

For questions or issues:
1. Check Documentation
2. Search Issues
3. Contact team lead

---

Built with ❤️ by Jordan Romero Porter – Demonstrating Staff-level iOS engineering
