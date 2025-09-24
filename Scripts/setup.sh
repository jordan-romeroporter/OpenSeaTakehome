#!/bin/bash

# One-command project setup

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

printf '%s\n' "🎯 Portfolio App Setup" "====================="

if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "❌ Xcode not found. Please install Xcode first."
    exit 1
fi

if ! command -v swiftlint >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
        echo "📦 Installing SwiftLint..."
        brew install swiftlint
    else
        echo "⚠️  Homebrew not found. Install SwiftLint manually."
    fi
fi

CONFIG_FILE="$PROJECT_DIR/Configuration/Secrets.xcconfig"

printf '%s\n' "🔐 Setting up API key configuration..."
if [ -f "$CONFIG_FILE" ]; then
    echo "🔁 Secrets file already exists at $CONFIG_FILE (skipping creation)"
else
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat <<'CONFIG' > "$CONFIG_FILE"
// Configuration file for API keys
// Add this file to version control ignore rules!
ALCHEMY_API_KEY = your_api_key_here
CONFIG
    echo "✅ Created $CONFIG_FILE"
fi

GITIGNORE_FILE="$PROJECT_DIR/.gitignore"
for pattern in "Configuration/Secrets.xcconfig" "*.xcconfig"; do
    if [ -f "$GITIGNORE_FILE" ] && grep -qxF "$pattern" "$GITIGNORE_FILE"; then
        continue
    fi
    echo "$pattern" >> "$GITIGNORE_FILE"
done

HOOK_PATH="$PROJECT_DIR/.git/hooks/pre-commit"

printf '%s\n' "🪝 Setting up pre-commit hooks..."
cat <<'HOOK' > "$HOOK_PATH"
#!/bin/bash
set -euo pipefail

if command -v swiftlint >/dev/null 2>&1; then
    swiftlint --quiet
else
    echo "SwiftLint not installed; skipping lint."
fi

CHANGED_FILES=$(git diff --staged --name-only)
if [ -n "$CHANGED_FILES" ]; then
    while IFS= read -r file; do
        [ -f "$file" ] || continue
        case "$file" in
            *.xcconfig) continue ;;
        esac
        if grep -Eq "api_key|apiKey|API_KEY" "$file"; then
            echo "⚠️  Warning: Possible API key in $file!"
            echo "Please use xcconfig or environment variables"
            exit 1
        fi
    done <<< "$CHANGED_FILES"
fi
HOOK
chmod +x "$HOOK_PATH"

printf '%s\n' "📚 Generating documentation..."
"$SCRIPT_DIR/generate-docs.sh"

cat <<'OUTRO'

✅ Setup complete!

📋 Next steps:
  1. Add your Alchemy API key to Configuration/Secrets.xcconfig
  2. Open OpenSeaTakehome.xcodeproj in Xcode
  3. Build and run (⌘R)

🔑 Get your API key at: https://dashboard.alchemy.com/
OUTRO
