#!/usr/bin/env bash
# verify-zeitwerk.sh — Verify Zeitwerk autoloading across all Workarea engines
#
# WA-VERIFY-058: https://github.com/workarea-commerce/workarea/issues/1023
# Zeitwerk notes: docs/rails7-migration-patterns/zeitwerk-notes.md
#
# Runs `zeitwerk:check` against each engine's dummy app using the default
# appraisal (root Gemfile.lock) and Ruby 2.7.8 via rbenv.
#
# Usage:
#   ./scripts/verify-zeitwerk.sh            # Check all three engines
#   ./scripts/verify-zeitwerk.sh core       # Core engine only
#   ./scripts/verify-zeitwerk.sh admin      # Admin engine only
#   ./scripts/verify-zeitwerk.sh storefront # Storefront engine only
#
# Requirements:
#   - Ruby 2.7.8 installed via rbenv  (install: rbenv install 2.7.8)
#   - Bundle installed at repo root  (bundle install)
#   - MongoDB running (zeitwerk:check boots the app)
#
# Exit codes:
#   0 — all checked engines passed
#   1 — one or more engines failed

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUBY_VERSION="2.7.8"
ENGINES=(core admin storefront)

# ─── Colour helpers (disabled when not a terminal) ────────────────────────────
if [[ -t 1 ]]; then
  GREEN="\033[0;32m"
  RED="\033[0;31m"
  YELLOW="\033[0;33m"
  BOLD="\033[1m"
  RESET="\033[0m"
else
  GREEN="" RED="" YELLOW="" BOLD="" RESET=""
fi

info()    { echo -e "${BOLD}[zeitwerk]${RESET} $*"; }
pass()    { echo -e "${GREEN}  ✓ PASS${RESET}  $*"; }
fail()    { echo -e "${RED}  ✗ FAIL${RESET}  $*"; }
warn()    { echo -e "${YELLOW}  ⚠ WARN${RESET}  $*"; }
ruler()   { echo "────────────────────────────────────────────────────────────────"; }

# ─── rbenv setup ──────────────────────────────────────────────────────────────
setup_ruby() {
  if command -v rbenv &>/dev/null; then
    export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init - bash 2>/dev/null || true)"
    if rbenv versions --bare 2>/dev/null | grep -qx "${RUBY_VERSION}"; then
      rbenv shell "${RUBY_VERSION}"
      info "Ruby $(ruby --version)"
    else
      warn "Ruby ${RUBY_VERSION} not found via rbenv. Using current: $(ruby --version)"
      warn "Install with: rbenv install ${RUBY_VERSION}"
    fi
  else
    warn "rbenv not found — using system Ruby: $(ruby --version)"
  fi
}

# ─── Run zeitwerk:check for a single engine ───────────────────────────────────
#
# zeitwerk:check must be run from inside the engine directory so that
# the dummy app's Rakefile is on the load path. We also pass
# BUNDLE_GEMFILE explicitly to keep the root lockfile active.
check_engine() {
  local engine="$1"
  local engine_dir="${REPO_ROOT}/${engine}"
  local dummy_dir="${engine_dir}/test/dummy"

  if [[ ! -d "$dummy_dir" ]]; then
    warn "${engine}: no dummy app at ${dummy_dir} — skipping"
    return 0
  fi

  info "Checking ${engine} …"

  local output exit_code=0
  output=$(
    cd "$engine_dir"
    BUNDLE_GEMFILE="${REPO_ROOT}/Gemfile" \
    RAILS_ENV=test \
      bundle exec bin/rails zeitwerk:check 2>&1
  ) || exit_code=$?

  if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q "All is good!"; then
    pass "${engine}: Zeitwerk OK"
    return 0
  else
    fail "${engine}: Zeitwerk check failed (exit ${exit_code})"
    echo "$output" | sed 's/^/    /'
    return 1
  fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  cd "$REPO_ROOT"

  # Resolve which engines to check
  if [[ $# -gt 0 ]]; then
    ENGINES=("$@")
  fi

  ruler
  info "Workarea Zeitwerk Autoload Check"
  info "Ruby target : ${RUBY_VERSION}"
  info "Engines     : ${ENGINES[*]}"
  info "Repo root   : ${REPO_ROOT}"
  ruler

  setup_ruby
  echo ""

  local failed=0
  local passed=0

  for engine in "${ENGINES[@]}"; do
    if check_engine "$engine"; then
      (( passed++ )) || true
    else
      (( failed++ )) || true
    fi
    echo ""
  done

  ruler
  if [[ $failed -eq 0 ]]; then
    pass "All ${passed} engine(s) passed Zeitwerk check."
    echo ""
    echo "  You're good to push. 🎉"
  else
    fail "${failed} engine(s) failed. ${passed} passed."
    echo ""
    echo "  Fix autoload errors before pushing."
    echo "  See docs/rails7-migration-patterns/zeitwerk-notes.md for guidance."
  fi
  ruler
  echo ""

  [[ $failed -eq 0 ]]
}

main "$@"
