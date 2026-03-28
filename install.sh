#!/bin/bash
# Visual Eyes - Install for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/nikolasdehor/visual-eyes/main/install.sh | bash
# Or: bash install.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

SKILL_DIR="$HOME/.claude/skills/visual-eyes"
REPO_URL="https://github.com/nikolasdehor/visual-eyes"
RAW_BASE="https://raw.githubusercontent.com/nikolasdehor/visual-eyes/main"

log()    { echo -e "${BLUE}[visual-eyes]${RESET} $*"; }
ok()     { echo -e "${GREEN}[visual-eyes]${RESET} $*"; }
warn()   { echo -e "${YELLOW}[visual-eyes]${RESET} WARNING: $*"; }
err()    { echo -e "${RED}[visual-eyes]${RESET} ERROR: $*" >&2; }

# Detect if we're running from inside the repo (local install)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
IS_LOCAL=false
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/skills/visual-eyes/SKILL.md" ]]; then
  IS_LOCAL=true
fi

echo ""
echo -e "${BOLD}Visual Eyes - Claude Code Skill${RESET}"
echo "────────────────────────────────"

# Detect update vs fresh install
if [[ -d "$SKILL_DIR" ]]; then
  log "Existing installation detected - updating..."
  IS_UPDATE=true
else
  log "Fresh installation..."
  IS_UPDATE=false
fi

# Check required tools
MISSING_TOOLS=()
if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
  MISSING_TOOLS+=("curl or wget")
fi
if [[ "$IS_LOCAL" == false ]] && ! command -v git &>/dev/null && ! command -v curl &>/dev/null; then
  MISSING_TOOLS+=("git or curl")
fi

if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
  err "Missing required tools: ${MISSING_TOOLS[*]}"
  err "Please install them and retry."
  exit 1
fi

# Check write permissions for skill dir parent
SKILLS_PARENT="$HOME/.claude/skills"
if [[ -d "$SKILLS_PARENT" ]] && [[ ! -w "$SKILLS_PARENT" ]]; then
  err "No write permission to $SKILLS_PARENT"
  err "Try: chmod u+w $SKILLS_PARENT"
  exit 1
fi

# Install files
mkdir -p "$SKILL_DIR/scripts"

if [[ "$IS_LOCAL" == true ]]; then
  log "Installing from local repo: $SCRIPT_DIR"
  cp "$SCRIPT_DIR/skills/visual-eyes/SKILL.md" "$SKILL_DIR/SKILL.md"
  cp "$SCRIPT_DIR/skills/visual-eyes/scripts/screenshot.sh" "$SKILL_DIR/scripts/screenshot.sh"
  cp "$SCRIPT_DIR/skills/visual-eyes/scripts/compare.sh"    "$SKILL_DIR/scripts/compare.sh"
elif command -v git &>/dev/null; then
  log "Cloning repository..."
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  if ! git clone --depth 1 --quiet "$REPO_URL" "$TMP/visual-eyes" 2>/dev/null; then
    err "git clone failed. Check your internet connection."
    exit 1
  fi
  cp "$TMP/visual-eyes/skills/visual-eyes/SKILL.md"            "$SKILL_DIR/SKILL.md"
  cp "$TMP/visual-eyes/skills/visual-eyes/scripts/screenshot.sh" "$SKILL_DIR/scripts/screenshot.sh"
  cp "$TMP/visual-eyes/skills/visual-eyes/scripts/compare.sh"    "$SKILL_DIR/scripts/compare.sh"
else
  log "Downloading files with curl..."
  if ! curl -fsSL "$RAW_BASE/skills/visual-eyes/SKILL.md" -o "$SKILL_DIR/SKILL.md"; then
    err "Failed to download SKILL.md. Check your internet connection."
    exit 1
  fi
  if ! curl -fsSL "$RAW_BASE/skills/visual-eyes/scripts/screenshot.sh" -o "$SKILL_DIR/scripts/screenshot.sh"; then
    err "Failed to download screenshot.sh"
    exit 1
  fi
  if ! curl -fsSL "$RAW_BASE/skills/visual-eyes/scripts/compare.sh" -o "$SKILL_DIR/scripts/compare.sh"; then
    err "Failed to download compare.sh"
    exit 1
  fi
fi

# Make scripts executable
chmod +x "$SKILL_DIR/scripts/screenshot.sh"
chmod +x "$SKILL_DIR/scripts/compare.sh"
ok "Skill files installed."

# Verify files are present
for f in "$SKILL_DIR/SKILL.md" "$SKILL_DIR/scripts/screenshot.sh" "$SKILL_DIR/scripts/compare.sh"; do
  if [[ ! -f "$f" ]]; then
    err "Expected file missing after install: $f"
    exit 1
  fi
done

# Check Playwright
echo ""
log "Checking Playwright..."
if command -v npx &>/dev/null; then
  if npx --yes playwright --version &>/dev/null 2>&1; then
    PLAYWRIGHT_VERSION="$(npx playwright --version 2>/dev/null || echo "unknown")"
    ok "Playwright found: $PLAYWRIGHT_VERSION"

    # Check if chromium browser is installed
    if ! npx playwright install --dry-run chromium 2>&1 | grep -q "browser is already installed" 2>/dev/null; then
      echo ""
      warn "Playwright Chromium browser may not be installed."
      # Only prompt if running interactively (stdin is a terminal)
      if [[ -t 0 ]]; then
        read -r -p "$(echo -e ${YELLOW}Install Chromium browser now? [Y/n]:${RESET} )" REPLY
        REPLY="${REPLY:-Y}"
      else
        REPLY="Y"
        log "Non-interactive mode - installing Chromium automatically..."
      fi
      if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        log "Installing Chromium (this may take a minute)..."
        if npx playwright install chromium 2>/dev/null; then
          ok "Chromium installed."
        else
          warn "Could not install Chromium automatically."
          warn "Run manually: npx playwright install chromium"
        fi
      else
        warn "Skipped. Run later: npx playwright install chromium"
      fi
    fi
  else
    warn "npx is available but Playwright is not installed globally."
    warn "The skill will install it on first use, or run: npm install -g playwright"
  fi
else
  warn "npx/Node.js not found. Playwright is required for screenshots."
  if [[ "$(uname)" == "Darwin" ]]; then
    warn "Install Node.js: brew install node  OR  https://nodejs.org"
  else
    warn "Install Node.js: https://nodejs.org"
  fi
fi

# Done
echo ""
echo "────────────────────────────────"
if [[ "$IS_UPDATE" == true ]]; then
  ok "${BOLD}Visual Eyes updated successfully!${RESET}"
else
  ok "${BOLD}Visual Eyes installed successfully!${RESET}"
fi
echo ""
echo "  Skill location: $SKILL_DIR"
echo ""
echo "  Restart Claude Code and try:"
echo "    /visual-eyes"
echo "    'screenshot the app'"
echo "    'how does the UI look?'"
echo ""
