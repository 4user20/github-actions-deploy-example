#!/usr/bin/env bash
set -euo pipefail

# Smoke test — checks critical endpoints.
# Usage: BASE_URL=http://localhost:3000 ./scripts/smoke-test.sh

BASE_URL="${BASE_URL:-http://localhost:3000}"
FAILED=0

check_endpoint() {
  local url="$1"
  local expected="$2"
  local label="$3"

  echo -n "Checking ${label} (${url})... "
  if response="$(curl -sf -o /dev/null -w "%{http_code}" "${url}" 2>&1)"; then
    echo "${response} (OK)"
  else
    echo "FAILED (exit code: ${response})"
    FAILED=1
  fi
}

check_endpoint "${BASE_URL}/health" "200" "Health endpoint"
check_endpoint "${BASE_URL}/api/me" "200|401" "API /me endpoint"

if [ "${FAILED}" -eq 1 ]; then
  echo "Smoke test FAILED"
  exit 1
fi

echo "All smoke tests passed"
