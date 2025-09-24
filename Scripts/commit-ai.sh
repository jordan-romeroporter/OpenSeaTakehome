#!/bin/bash

# AI-powered commit message generator following conventions

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}❌ jq is required but not installed${NC}"
    echo "Install jq (brew install jq) and try again."
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}❌ curl is required but not installed${NC}"
    exit 1
fi

if [ -z "${OPENAI_API_KEY-}" ]; then
    echo -e "${RED}❌ OPENAI_API_KEY environment variable not set${NC}"
    exit 1
fi

STAGED_DIFF=$(git diff --staged)

if [ -z "$STAGED_DIFF" ]; then
    echo -e "${RED}❌ No staged changes found${NC}"
    echo "Please stage your changes first: git add <files>"
    exit 1
fi

PROMPT="Based on these git changes, generate a conventional commit message.
Use format: <type>: <description>
Types: feat, fix, docs, style, refactor, test, chore, perf
Keep description under 50 chars.
Be specific about what changed.

Changes:
$STAGED_DIFF"

echo -e "${YELLOW}🤖 Analyzing changes...${NC}"

COMMIT_MSG=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{\
    \"model\": \"gpt-3.5-turbo\",\
    \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}],\
    \"max_tokens\": 100\
  }" | jq -r '.choices[0].message.content // empty')

if [ -z "$COMMIT_MSG" ]; then
    echo -e "${RED}❌ Failed to generate commit message${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Generated commit message:${NC}"
echo "$COMMIT_MSG"
echo ""
read -r -p "Use this commit message? (y/n/e to edit): " CHOICE

case "$CHOICE" in
    y|Y )
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✅ Committed successfully!${NC}"
        ;;
    e|E )
        git commit -e -m "$COMMIT_MSG"
        ;;
    * )
        echo "Commit cancelled"
        ;;
esac
