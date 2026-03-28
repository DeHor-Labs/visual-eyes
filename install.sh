#!/bin/bash
# Visual Eyes - Install for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/nikolasdehor/visual-eyes/main/install.sh | bash

set -e
SKILL_DIR="$HOME/.claude/skills/visual-eyes"
REPO="https://github.com/nikolasdehor/visual-eyes"

echo "Installing Visual Eyes..."

# Clone or download
if command -v git &> /dev/null; then
  TMP=$(mktemp -d)
  git clone --depth 1 "$REPO" "$TMP/visual-eyes" 2>/dev/null
  mkdir -p "$SKILL_DIR/scripts"
  cp "$TMP/visual-eyes/skills/visual-eyes/SKILL.md" "$SKILL_DIR/"
  cp "$TMP/visual-eyes/skills/visual-eyes/scripts/"*.sh "$SKILL_DIR/scripts/"
  chmod +x "$SKILL_DIR/scripts/"*.sh
  rm -rf "$TMP"
else
  # Fallback: download files directly
  mkdir -p "$SKILL_DIR/scripts"
  curl -fsSL "$REPO/raw/main/skills/visual-eyes/SKILL.md" -o "$SKILL_DIR/SKILL.md"
  curl -fsSL "$REPO/raw/main/skills/visual-eyes/scripts/screenshot.sh" -o "$SKILL_DIR/scripts/screenshot.sh"
  curl -fsSL "$REPO/raw/main/skills/visual-eyes/scripts/compare.sh" -o "$SKILL_DIR/scripts/compare.sh"
  chmod +x "$SKILL_DIR/scripts/"*.sh
fi

# Check Playwright
if ! npx playwright --version &> /dev/null 2>&1; then
  echo "Installing Playwright browsers..."
  npx playwright install chromium 2>/dev/null || echo "Warning: Could not install browsers. Run: npx playwright install chromium"
fi

echo ""
echo "Visual Eyes installed successfully!"
echo "Restart Claude Code and use: /visual-eyes"
echo "Or just say: 'screenshot the app' or 'how does the UI look?'"
