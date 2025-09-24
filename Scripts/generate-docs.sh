#!/bin/bash

# Living documentation generator

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCS_DIR="$PROJECT_DIR/Documentation"

printf '%s\n' "📚 Generating documentation..."

mkdir -p "$DOCS_DIR/ADR"

cat <<'ADR' > "$DOCS_DIR/ADR/001-architecture-pattern.md"
# ADR-001: Clean Architecture with MVVM-C

## Status
Accepted

## Context
Need scalable architecture for team growth and feature development.

## Decision
Use Clean Architecture with MVVM-Coordinator pattern:
- **Clean Architecture**: Clear separation of concerns
- **MVVM**: SwiftUI-friendly reactive pattern
- **Coordinator**: Navigation logic separation

## Consequences
✅ Testable layers  
✅ Team can work independently  
✅ Easy onboarding  
❌ Initial boilerplate  
❌ Learning curve for juniors  

## Mitigation
- Code generation scripts
- Comprehensive examples
- Pair programming sessions
ADR

cat <<'ADR2' > "$DOCS_DIR/ADR/002-dependency-injection.md"
# ADR-002: Protocol-Oriented Dependency Injection

## Status
Accepted

## Context
Avoid singletons and tight coupling for better testability.

## Decision
Protocol-oriented DI with Container pattern.

## Implementation
```swift
protocol Service {}
container.register(Service.self, ServiceImpl())
let service = container.resolve(Service.self)
```

## Consequences
✅ Easy mocking  
✅ Clear dependencies  
✅ Compile-time safety  
ADR2

cat <<'APIDOC' > "$DOCS_DIR/API_KEY_SETUP.md"
# API Key Configuration Guide

## Quick Start
1. Get API key from [Alchemy Dashboard](https://dashboard.alchemy.com/)
2. Add to `Configuration/Secrets.xcconfig`:
   ```
   ALCHEMY_API_KEY = your_key_here
   ```

## Configuration Methods

### Method 1: Build Configuration (Recommended)
- Best for: Local development
- Security: ⭐⭐⭐⭐

### Method 2: Environment Variables
- Best for: CI/CD
- Security: ⭐⭐⭐⭐⭐

### Method 3: Inline (Development Only)
- Best for: Quick demos
- Security: ⭐

## Troubleshooting
- Verify key in Xcode: Product → Scheme → Edit Scheme
- Check Info.plist contains: $(ALCHEMY_API_KEY)
- Ensure xcconfig is linked in project settings
APIDOC

cat <<'CONTRIB' > "$DOCS_DIR/CONTRIBUTING.md"
# Contributing to Portfolio App

## 🎯 Philosophy
We optimize for:
1. **Developer velocity** - Ship fast, maintain quality
2. **Team scalability** - Easy onboarding, clear patterns
3. **User delight** - Performance, accessibility, reliability

## 🏗 Architecture

### Feature Structure
```
Features/
└── FeatureName/
    ├── Domain/       # Business logic
    ├── Data/         # API/Database
    ├── Presentation/ # Views/ViewModels
    └── Coordinator/  # Navigation
```

### Creating Features
```bash
./create-feature.sh MyFeature
```

## 📝 Code Style

### Naming
- **Views**: `FeatureNameView`
- **ViewModels**: `FeatureNameViewModel`
- **Services**: `FeatureNameService`

### Documentation
- Public APIs need doc comments
- Complex logic needs inline comments
- ADRs for architectural decisions

## 🔄 Git Workflow

### Commits
Use conventional commits:
```bash
./commit-ai.sh  # AI-powered commit messages
```

### Pull Requests
Fill out template:
- What changed?
- Why?
- Screenshots
- Testing steps

## ✅ Testing

### Unit Tests
- ViewModels: Required
- Services: Required
- Views: Optional

### UI Tests
- Happy path: Required
- Edge cases: Recommended

### Accessibility Tests
- VoiceOver: Required
- Dynamic Type: Required

## 🚀 Release Process
1. Feature branch → PR
2. Code review (1 approval minimum)
3. CI passes
4. Merge to main
5. Auto-deploy to TestFlight

## 📊 Metrics We Track
- Build time
- Test coverage
- Crash rate
- User engagement
CONTRIB

printf '%s\n' "✅ Documentation generated!"
