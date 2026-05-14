.PHONY: ci-check build-docker deploy-staging deploy-production rollback healthcheck

# CI — local checks (no external services)
ci-check:
	@echo "Running CI checks (placeholder)..."
	@cd app && npm ci && npm run typecheck && npm run lint

# Build Docker image locally
build-docker:
	@echo "Building Docker image..."
	docker build -t ci-cd-demo-app:latest ./app

# Deploy to staging (requires SSH access + env vars)
deploy-staging:
	@echo "Deploying to staging..."
	@./scripts/deploy.sh

# Deploy to production (requires SSH access + env vars)
deploy-production:
	@echo "Deploying to production..."
	@./scripts/deploy.sh

# Rollback to previous image
rollback:
	@echo "Rolling back..."
	@./scripts/rollback.sh

# Healthcheck
healthcheck:
	@echo "Running healthcheck..."
	@./scripts/healthcheck.sh
