#!/usr/bin/env bash
set -euo pipefail

# Healthcheck — retries until the service responds or max attempts reached.
# Usage: HEALTHCHECK_URL=http://localhost:3000/health ./scripts/healthcheck.sh

URL="${HEALTHCHECK_URL:-http://localhost:3000/health}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-30}"
DELAY="${DELAY:-2}"

echo "Healthcheck: ${URL}"

for i in $(seq 1 "${MAX_ATTEMPTS}"); do
  if curl -sf "${URL}" > /dev/null 2>&1; then
    echo "Healthcheck passed (attempt ${i})"
    exit 0
  fi
  echo "Waiting... (attempt ${i}/${MAX_ATTEMPTS})"
  sleep "${DELAY}"
done

echo "Healthcheck failed after ${MAX_ATTEMPTS} attempts"
exit 1
