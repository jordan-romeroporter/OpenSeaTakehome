#!/bin/bash

printf '%s\n' "♿ Running Accessibility Audit..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_DIR="$PROJECT_DIR/OpenSeaTakehome"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Could not find source directory at $TARGET_DIR"
    exit 1
fi

printf '%s\n' "Checking for missing accessibility labels..."
MISSING_LABELS=$(grep -RE "Text\(|Button\(|Image\(" --include="*.swift" "$TARGET_DIR" | grep -v "accessibilityLabel" || true)
if [ -n "$MISSING_LABELS" ]; then
    printf '%s\n' "⚠️  Views missing accessibility labels:" "$(echo "$MISSING_LABELS" | head -5)"
else
    echo "✅ No obvious missing labels detected"
fi

printf '%s\n' "Checking semantic grouping..."
grep -RE "\\.accessibilityElement\(children: \\.combine\)" --include="*.swift" "$TARGET_DIR" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "⚠️  Consider using .accessibilityElement(children: .combine) for grouped content"
else
    echo "✅ Found grouped accessibility elements"
fi

printf '%s\n' "Checking Dynamic Type support..."
FIXED_FONTS=$(grep -RE "\\.font\(.system\(size: [0-9]" --include="*.swift" "$TARGET_DIR" || true)
if [ -n "$FIXED_FONTS" ]; then
    printf '%s\n' "⚠️  Fixed font sizes found (breaks Dynamic Type):" "$(echo "$FIXED_FONTS" | head -3)"
else
    echo "✅ No fixed font sizes detected"
fi

printf '%s\n' "✅ Accessibility audit complete!"
