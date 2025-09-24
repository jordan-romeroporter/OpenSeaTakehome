#!/bin/bash

# Portfolio App Alias Installer
# Detects shell and installs developer productivity aliases

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

printf '%s\n' "🚀 Portfolio App Developer Tools Installer" "========================================="

# Detect shell
if [ -n "${ZSH_VERSION-}" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "${BASH_VERSION-}" ]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo "❌ Unsupported shell. Please manually add aliases."
    exit 1
fi

printf '%s\n' "📋 Detected shell: $SHELL_NAME" "📝 Config file: $SHELL_RC"

# Check if aliases already exist
if grep -q "Portfolio App Developer Tools" "$SHELL_RC" 2>/dev/null; then
    cat <<'EOM'
✅ Aliases already installed!

Available commands:
  pf-commit  - AI-powered commit messages
  pf-feature - Create new feature module
  pf-audit   - Run accessibility audit
  pf-docs    - Generate documentation
  pf-setup   - Initial project setup
  pf-test    - Run Swift tests
  pf-build   - Build project
  pf-clean   - Clean build
EOM
    exit 0
fi

{
    echo ""
    echo "# Portfolio App Developer Tools"
    echo "# Added on $(date)"
} >> "$SHELL_RC"

cat <<ALIASES >> "$SHELL_RC"
# Core tools
alias pf-commit="\"$PROJECT_DIR/Scripts/commit-ai.sh\""
alias pf-feature="\"$PROJECT_DIR/Scripts/create-feature.sh\""
alias pf-audit="\"$PROJECT_DIR/Scripts/accessibility-audit.sh\""
alias pf-docs="\"$PROJECT_DIR/Scripts/generate-docs.sh\""
alias pf-setup="\"$PROJECT_DIR/Scripts/setup.sh\""

# Build & test shortcuts
alias pf-test="cd $PROJECT_DIR && swift test"
alias pf-build="cd $PROJECT_DIR && xcodebuild -scheme Portfolio build"
alias pf-clean="cd $PROJECT_DIR && xcodebuild clean"
alias pf-run="cd $PROJECT_DIR && xcodebuild -scheme Portfolio -destination 'platform=iOS Simulator,name=iPhone 15 Pro' run"

# Advanced commands
alias pf-coverage="cd $PROJECT_DIR && xcodebuild test -scheme Portfolio -enableCodeCoverage YES"
alias pf-lint="cd $PROJECT_DIR && swiftlint"
alias pf-format="cd $PROJECT_DIR && swiftlint --fix"
alias pf-profile="cd $PROJECT_DIR && instruments -t 'Time Profiler' -D profile.trace"

# Git helpers
alias pf-pr="gh pr create --fill"
alias pf-sync="cd $PROJECT_DIR && git pull --rebase origin main"
alias pf-branch="git checkout -b"

# Quick navigation
alias pf-cd="cd $PROJECT_DIR"
alias pf-open="open $PROJECT_DIR/Portfolio.xcodeproj"
ALIASES

cat <<'INFO'

✅ Aliases installed successfully!

🎯 Available commands:

  Core Tools:
    pf-commit    - AI-powered commit messages
    pf-feature   - Create new feature module
    pf-audit     - Run accessibility audit
    pf-docs      - Generate documentation
    pf-setup     - Initial project setup

  Build & Test:
    pf-test      - Run Swift tests
    pf-build     - Build project
    pf-clean     - Clean build
    pf-run       - Build and run in simulator
    pf-coverage  - Generate test coverage

  Code Quality:
    pf-lint      - Run SwiftLint
    pf-format    - Auto-fix linting issues
    pf-profile   - Run performance profiler

  Git Workflow:
    pf-pr        - Create pull request
    pf-sync      - Sync with main branch
    pf-branch    - Create new branch

  Navigation:
    pf-cd        - Navigate to project
    pf-open      - Open in Xcode

📌 To activate now, run: source $SHELL_RC
📚 Or restart your terminal
INFO

read -p "Would you like to activate aliases now? (y/n): " -n 1 -r
printf '\n'
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # shellcheck disable=SC1090
    source "$SHELL_RC"
    echo "✨ Aliases activated! Try 'pf-' and hit TAB for autocomplete"
fi
