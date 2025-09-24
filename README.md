# Portfolio iOS App

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
   echo "ALCHEMY_API_KEY = your_key_here" > Secrets.xcconfig
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

Built with ❤️ by Jordan Romero Porter
