#!/bin/bash

# Colors for better visibility (optional but nice)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Checking for staged changes...${NC}"
# Check if there are staged changes
if [ -z "$(git diff --staged)" ]; then
    echo -e "${RED}❌ No staged changes found. Please stage some changes first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Found staged changes${NC}"

echo -e "${YELLOW}🔧 Checking Claude Code installation...${NC}"
# Check if claude command exists
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code is not installed or not in PATH${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Claude Code is available${NC}"

echo -e "${YELLOW}📝 Getting staged diff...${NC}"
# Get the staged diff with file names
DIFF=$(git diff --staged)
FILES_CHANGED=$(git diff --staged --name-only)
echo -e "${GREEN}✓ Captured diff ($(echo "$DIFF" | wc -l) lines)${NC}"
echo -e "${GREEN}✓ Files changed: $(echo "$FILES_CHANGED" | wc -l)${NC}"

echo -e "${YELLOW}🤖 Asking Claude to generate commit message...${NC}"
echo -e "${YELLOW}   This may take a few seconds...${NC}"

# Enhanced prompt for more detailed commit messages
COMMIT_MSG=$(echo "Review this git diff and generate a comprehensive multi-line conventional commit message.

IMPORTANT REQUIREMENTS:
1. Start with ONE main conventional commit type (feat/fix/docs/style/refactor/test/chore/perf) that represents the primary change
2. Format: 'type(scope): brief description' for the first line (keep under 72 chars)
3. Leave a blank line after the first line
4. Then provide a detailed body with:
   - A brief paragraph explaining the overall change
   - A bulleted list of ALL individual changes, grouped by type if multiple types exist
   - Each bullet should be specific and mention the file/component affected
   - Use format like: '- feat: added user authentication to login.js'
   - Include ALL changes, even minor ones
5. Be comprehensive - I want to be able to understand what changed without looking at the diff
6. If there are breaking changes, add 'BREAKING CHANGE:' section at the end

Files changed:
$FILES_CHANGED

Diff:
$DIFF

Output ONLY the commit message in the exact format requested, nothing else. No explanations, no markdown code blocks, just the commit message itself." | claude 2>&1)

# Check if Claude returned an error
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: Failed to generate commit message${NC}"
    echo -e "${RED}Claude output: $COMMIT_MSG${NC}"
    exit 1
fi

# Check if commit message is empty
if [ -z "$COMMIT_MSG" ]; then
    echo -e "${RED}❌ Error: Generated commit message is empty${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Commit message generated successfully${NC}"
echo ""
echo -e "${GREEN}📋 Generated commit message:${NC}"
echo -e "${YELLOW}------------------------${NC}"
echo "$COMMIT_MSG"
echo -e "${YELLOW}------------------------${NC}"
echo ""

# Count lines in commit message for feedback
LINE_COUNT=$(echo "$COMMIT_MSG" | wc -l)
echo -e "${GREEN}📊 Message details: $LINE_COUNT lines${NC}"
echo ""

# Ask for confirmation with options
echo -e "${GREEN}Options:${NC}"
echo -e "  ${YELLOW}y${NC} - Use this commit message"
echo -e "  ${YELLOW}e${NC} - Edit the message before committing"
echo -e "  ${YELLOW}r${NC} - Regenerate the message"
echo -e "  ${YELLOW}n${NC} - Cancel"
read -p "$(echo -e ${GREEN}Your choice: ${NC})" -n 1 -r CHOICE
echo

case $CHOICE in
    [Yy])
        echo -e "${YELLOW}💾 Creating commit...${NC}"
        git commit -m "$COMMIT_MSG"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✨ Commit created successfully!${NC}"
        else
            echo -e "${RED}❌ Error: Failed to create commit${NC}"
            exit 1
        fi
        ;;
    [Ee])
        echo -e "${YELLOW}📝 Opening editor for commit message...${NC}"
        # Save to temp file and open in git's default editor
        TEMP_FILE=$(mktemp)
        echo "$COMMIT_MSG" > "$TEMP_FILE"
        git commit -e -F "$TEMP_FILE"
        rm "$TEMP_FILE"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✨ Commit created successfully with edits!${NC}"
        else
            echo -e "${RED}❌ Error: Failed to create commit or commit was cancelled${NC}"
            exit 1
        fi
        ;;
    [Rr])
        echo -e "${YELLOW}🔄 Regenerating...${NC}"
        exec "$0"
        ;;
    *)
        echo -e "${YELLOW}❌ Commit cancelled${NC}"
        ;;
esac
