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

cat <<'OUTRO'

✅ Setup complete!

📋 Next steps:
1. Add your Alchemy API key to Configuration/Secrets.xcconfig
2. Open OpenSeaTakehome.xcodeproj in Xcode
3. Build and run (⌘R)

🔑 Get your API key at: https://dashboard.alchemy.com/
OUTRO
