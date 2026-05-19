#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$ROOT_DIR/install.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    fail "Expected output to contain: $needle"
  fi
}

run_capture() {
  local output_file="$1"
  shift

  set +e
  "$@" >"$output_file" 2>&1
  local status=$?
  set -e

  return "$status"
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
BIN_DIR="$TMP_DIR/bin"
mkdir -p "$BIN_DIR"

cat >"$BIN_DIR/npx" <<'SH'
#!/usr/bin/env bash
exit 1
SH
chmod +x "$BIN_DIR/npx"

HELP_OUTPUT="$TMP_DIR/help.out"
HELP_HOME="$TMP_DIR/help-home"
mkdir -p "$HELP_HOME"
if ! run_capture "$HELP_OUTPUT" env HOME="$HELP_HOME" PATH="$BIN_DIR:$PATH" bash "$INSTALL_SH" --help; then
  fail "install.sh --help should exit 0"
fi
HELP_TEXT="$(cat "$HELP_OUTPUT")"
assert_contains "$HELP_TEXT" "Usage:"
assert_contains "$HELP_TEXT" "--dry-run"
assert_contains "$HELP_TEXT" "--help"

DRY_HOME="$TMP_DIR/home"
mkdir -p "$DRY_HOME"
DRY_OUTPUT="$TMP_DIR/dry-run.out"
if ! run_capture "$DRY_OUTPUT" env HOME="$DRY_HOME" PATH="$BIN_DIR:$PATH" bash "$INSTALL_SH" --dry-run; then
  fail "install.sh --dry-run should exit 0"
fi
DRY_TEXT="$(cat "$DRY_OUTPUT")"
assert_contains "$DRY_TEXT" "Dry run"
assert_contains "$DRY_TEXT" "$DRY_HOME/.claude/skills/visual-eyes/SKILL.md"
assert_contains "$DRY_TEXT" "$DRY_HOME/.claude/skills/visual-eyes/scripts/screenshot.sh"
assert_contains "$DRY_TEXT" "$DRY_HOME/.claude/skills/visual-eyes/scripts/compare.sh"
if [[ -e "$DRY_HOME/.claude/skills/visual-eyes" ]]; then
  fail "install.sh --dry-run should not create the skill directory"
fi

BAD_FLAG_OUTPUT="$TMP_DIR/bad-flag.out"
BAD_FLAG_HOME="$TMP_DIR/bad-flag-home"
mkdir -p "$BAD_FLAG_HOME"
if run_capture "$BAD_FLAG_OUTPUT" env HOME="$BAD_FLAG_HOME" PATH="$BIN_DIR:$PATH" bash "$INSTALL_SH" --not-a-real-flag; then
  fail "install.sh should reject unknown flags"
fi
assert_contains "$(cat "$BAD_FLAG_OUTPUT")" "Unknown option"

if ! shellcheck "$INSTALL_SH" "$ROOT_DIR/tests/sanity.sh" "$ROOT_DIR/tests/validate.sh"; then
  fail "shellcheck reported issues"
fi

echo "sanity checks passed"
