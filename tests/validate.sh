#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$ROOT_DIR/install.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    fail "Expected file to exist: $file"
  fi
}

assert_executable() {
  local file="$1"

  if [[ ! -x "$file" ]]; then
    fail "Expected file to be executable: $file"
  fi
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

BIN_DIR="$TMP_DIR/bin"
HOME_DIR="$TMP_DIR/home"
INSTALL_OUTPUT="$TMP_DIR/install.out"
mkdir -p "$BIN_DIR" "$HOME_DIR"

cat >"$BIN_DIR/npx" <<'SH'
#!/usr/bin/env bash
exit 1
SH
chmod +x "$BIN_DIR/npx"

env HOME="$HOME_DIR" PATH="$BIN_DIR:$PATH" bash "$INSTALL_SH" >"$INSTALL_OUTPUT" 2>&1

SKILL_DIR="$HOME_DIR/.claude/skills/visual-eyes"
SKILL_FILE="$SKILL_DIR/SKILL.md"
SCREENSHOT_SCRIPT="$SKILL_DIR/scripts/screenshot.sh"
COMPARE_SCRIPT="$SKILL_DIR/scripts/compare.sh"

assert_file "$SKILL_FILE"
assert_file "$SCREENSHOT_SCRIPT"
assert_file "$COMPARE_SCRIPT"
assert_executable "$SCREENSHOT_SCRIPT"
assert_executable "$COMPARE_SCRIPT"

cmp -s "$ROOT_DIR/skills/visual-eyes/SKILL.md" "$SKILL_FILE" \
  || fail "Installed SKILL.md does not match repository source"
cmp -s "$ROOT_DIR/skills/visual-eyes/scripts/screenshot.sh" "$SCREENSHOT_SCRIPT" \
  || fail "Installed screenshot.sh does not match repository source"
cmp -s "$ROOT_DIR/skills/visual-eyes/scripts/compare.sh" "$COMPARE_SCRIPT" \
  || fail "Installed compare.sh does not match repository source"

grep -q '^---$' "$SKILL_FILE" || fail "SKILL.md is missing frontmatter"
grep -q '^name: visual-eyes$' "$SKILL_FILE" || fail "SKILL.md has invalid skill name"
grep -q '^description:' "$SKILL_FILE" || fail "SKILL.md is missing description"
grep -q 'scripts/screenshot.sh' "$SKILL_FILE" || fail "SKILL.md does not reference screenshot helper"
grep -q 'scripts/compare.sh' "$SKILL_FILE" || fail "SKILL.md does not reference compare helper"

echo "validate checks passed"
