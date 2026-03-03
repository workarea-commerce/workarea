#!/usr/bin/env bash
# run-benchmarks.sh — Reproduce Workarea test suite performance baseline measurements
#
# WA-PERF-002: https://github.com/workarea-commerce/workarea/issues/728
# Baseline doc: docs/benchmarks/test-suite-baseline-rails-6.1.md
#
# Usage:
#   ./scripts/run-benchmarks.sh            # Run all measurements
#   ./scripts/run-benchmarks.sh boot       # Boot time only
#   ./scripts/run-benchmarks.sh core       # Core engine tests only
#   ./scripts/run-benchmarks.sh admin      # Admin engine tests only
#   ./scripts/run-benchmarks.sh storefront # Storefront engine tests only
#   ./scripts/run-benchmarks.sh env        # Print environment info only
#
# Requirements:
#   - Ruby 3.2.7 via rbenv (rbenv shell 3.2.7)
#   - Docker services running: workarea-redis-1, workarea-mongo-1, workarea-elasticsearch-1
#   - Run from the repository root: /path/to/workarea/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${REPO_ROOT}/tmp/benchmarks"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# Ensure Ruby path is set
if command -v rbenv &>/dev/null; then
  export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - bash 2>/dev/null || true)"
  rbenv shell 3.2.7 2>/dev/null || echo "[WARN] rbenv shell 3.2.7 failed — using current Ruby"
fi

# Rails 6.1 + Ruby 3.2 workaround: require 'logger' before ActiveSupport loads
export RUBYOPT="-r logger"
export RAILS_ENV=test

cd "$REPO_ROOT"

mkdir -p "$LOG_DIR"

# ─────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────

print_header() {
  echo ""
  echo "════════════════════════════════════════"
  echo "  $1"
  echo "════════════════════════════════════════"
}

print_env() {
  print_header "Environment"
  echo "Ruby:          $(ruby --version 2>&1)"
  echo "Bundler:       $(bundle --version 2>&1)"
  echo "Rails:         $(bundle exec ruby -e "require 'rails'; puts Rails.version" 2>&1)"
  echo "Mongoid:       $(bundle exec ruby -e "require 'mongoid'; puts Mongoid::VERSION" 2>&1)"
  echo "Elasticsearch: $(curl -s localhost:9200 | python3 -m json.tool 2>/dev/null | grep '"number"' | tr -d ' "' | cut -d: -f2 | tr -d ',')"
  echo "Git branch:    $(git branch --show-current)"
  echo "Git commit:    $(git rev-parse --short HEAD)"
  echo ""
  echo "Docker services:"
  docker ps --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  (docker not available)"
}

measure_boot_time() {
  print_header "Boot Time (3 runs)"
  local times=()
  for i in 1 2 3; do
    echo -n "  Run $i: "
    local start end elapsed
    start=$(date +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000))")
    RAILS_ENV=test bundle exec ruby -e \
      "require File.expand_path('test/dummy/config/application', Dir.pwd); Rails.application.initialize!" \
      2>/dev/null
    end=$(date +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time()*1000))")
    # Fallback to time builtin
    TIMEFORMAT='%Rs'
    elapsed=$( { time RAILS_ENV=test bundle exec ruby -e \
      "require File.expand_path('test/dummy/config/application', Dir.pwd); Rails.application.initialize!" \
      2>/dev/null; } 2>&1 )
    echo "$elapsed"
    times+=("$elapsed")
  done
}

run_engine_tests() {
  local engine="$1"
  local log_file="${LOG_DIR}/${engine}-${TIMESTAMP}.log"
  print_header "Engine: $engine"
  echo "  Log: $log_file"
  echo "  Started: $(date)"
  cd "${REPO_ROOT}/${engine}"
  { time RAILS_ENV=test bundle exec rake app:test 2>&1 | tee "$log_file"; } 2>&1
  local exit_code=$?
  echo ""
  echo "  Finished: $(date)"
  echo "  Summary:"
  tail -5 "$log_file" | grep -E "runs|Finished" | sed 's/^/    /'
  cd "$REPO_ROOT"
  return $exit_code
}

measure_memory() {
  local engine="$1"
  local test_file="$2"
  print_header "Memory: $engine (single file)"
  echo "  Test file: $test_file"
  cd "${REPO_ROOT}/${engine}"
  RAILS_ENV=test bundle exec ruby -Itest "$test_file" 2>/dev/null &
  local TESTPID=$!
  local MAX_RSS=0
  while kill -0 $TESTPID 2>/dev/null; do
    local RSS
    RSS=$(ps -o rss= -p $TESTPID 2>/dev/null | tr -d ' ' || echo 0)
    if [[ -n "$RSS" && "$RSS" -gt "$MAX_RSS" ]] 2>/dev/null; then
      MAX_RSS=$RSS
    fi
    sleep 0.5
  done
  wait $TESTPID
  echo "  Peak RSS: $(( MAX_RSS / 1024 )) MB (${MAX_RSS} KB)"
  cd "$REPO_ROOT"
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────

MODE="${1:-all}"

case "$MODE" in
  env)
    print_env
    ;;
  boot)
    print_env
    measure_boot_time
    ;;
  core)
    print_env
    run_engine_tests "core"
    ;;
  admin)
    print_env
    run_engine_tests "admin"
    ;;
  storefront)
    print_env
    run_engine_tests "storefront"
    ;;
  all)
    print_header "Workarea Test Suite Benchmark"
    echo "  Timestamp: $TIMESTAMP"
    echo "  Logs: $LOG_DIR"

    print_env

    measure_boot_time

    echo ""
    echo "NOTE: Full test suite run will take ~45–60 minutes."
    echo "      Boot time captured. Starting engine test runs..."
    echo ""

    run_engine_tests "core"    || true
    run_engine_tests "admin"   || true
    run_engine_tests "storefront" || true

    # Memory snapshots (single test file, representative)
    measure_memory "core" "test/models/workarea/content_test.rb" || true

    print_header "SUMMARY"
    echo "  Logs saved to: $LOG_DIR"
    echo ""
    for engine in core admin storefront; do
      local_log="${LOG_DIR}/${engine}-${TIMESTAMP}.log"
      if [[ -f "$local_log" ]]; then
        echo "  $engine:"
        tail -5 "$local_log" | grep -E "runs|Finished" | sed 's/^/    /' || true
      fi
    done
    ;;
  *)
    echo "Usage: $0 [all|boot|env|core|admin|storefront]"
    exit 1
    ;;
esac
