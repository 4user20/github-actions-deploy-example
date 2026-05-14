#!/usr/bin/env bash
set -euo pipefail

# Deployment script
# Usage: REGISTRY=ghcr.io REPOSITORY=my-org/my-repo TAG=v1.2.3 ./scripts/deploy.sh

REGISTRY="${REGISTRY:-ghcr.io}"
REPOSITORY="${REPOSITORY:?REPOSITORY is required}"
TAG="${TAG:-latest}"
COMPOSE_DIR="$(cd "$(dirname "$0")/../docker" && pwd)"
COMPOSE_FILE="${COMPOSE_DIR}/compose.deploy.yml"

echo "Deploying ${REGISTRY}/${REPOSITORY}:${TAG}"

export REPOSITORY IMAGE_TAG="${TAG}"

# Login to registry
echo "${GITHUB_TOKEN}" | docker login "${REGISTRY}" -u "${GITHUB_ACTOR:-deploy}" --password-stdin

# Pull the image
docker compose -f "${COMPOSE_FILE}" pull app

# Start services
docker compose -f "${COMPOSE_FILE}" up -d --remove-orphans

# Run healthcheck
"$(dirname "$0")/healthcheck.sh"

echo "Deployment of ${TAG} complete"
