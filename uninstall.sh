#!/bin/bash
# Visual Eyes - Uninstall from Claude Code

set -euo pipefail

SKILL_DIR="$HOME/.claude/skills/visual-eyes"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}Visual Eyes - Uninstall${RESET}"
echo "────────────────────────"

if [[ ! -d "$SKILL_DIR" ]]; then
  echo -e "${YELLOW}[visual-eyes]${RESET} Not installed (directory not found: $SKILL_DIR)"
  exit 0
fi

echo "  This will delete: $SKILL_DIR"
echo ""
read -r -p "$(echo -e ${YELLOW}Are you sure? [y/N]:${RESET} )" REPLY </dev/tty || REPLY="N"
REPLY="${REPLY:-N}"

if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Uninstall cancelled."
  exit 0
fi

rm -rf "$SKILL_DIR"
echo -e "${GREEN}[visual-eyes]${RESET} ${BOLD}Uninstalled successfully.${RESET}"
echo ""
