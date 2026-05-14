#!/usr/bin/env bash
set -euo pipefail

# Rollback script — tags the "previous" image back to "latest" and restarts.
# Usage: REGISTRY=ghcr.io REPOSITORY=my-org/my-repo ./scripts/rollback.sh

REGISTRY="${REGISTRY:-ghcr.io}"
REPOSITORY="${REPOSITORY:?REPOSITORY is required}"
COMPOSE_DIR="$(cd "$(dirname "$0")/../docker" && pwd)"
COMPOSE_FILE="${COMPOSE_DIR}/compose.deploy.yml"

IMAGE="${REGISTRY}/${REPOSITORY}"

echo "Rolling back ${IMAGE}:previous -> ${IMAGE}:latest"

# Promote "previous" to "latest"
docker tag "${IMAGE}:previous" "${IMAGE}:latest"

# Restart services
docker compose -f "${COMPOSE_FILE}" up -d --remove-orphans

# Run healthcheck
"$(dirname "$0")/healthcheck.sh"

echo "Rollback complete"
