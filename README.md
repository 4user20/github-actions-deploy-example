# GitHub Actions Deploy Example

> Example GitHub Actions CI/CD pipeline for a TypeScript/Docker app - lint, typecheck, tests, Docker build, vulnerability scan, and deployment scripts.

## Pipeline Architecture

```
Push to GitHub
    ↓
CI: Tests + Security Scan
    ↓
Build Docker Image
    ↓
Deploy to Staging (auto)
    ↓
Manual Approval
    ↓
Deploy to Production
    ↓
Health Check
```

## What This Pipeline Does

- Automated testing (unit, integration)
- Security audit with npm audit and Trivy container scanning
- Docker multi-stage build with layer caching
- Automatic staging deployment on develop branch
- Production deployment with manual approval
- Database migrations via Prisma
- Post-deployment health checks
- Notifications via Slack (optional, requires SLACK_WEBHOOK_URL)

## Prerequisites

- GitHub repository
- Self-hosted or GitHub-hosted runner
- Docker registry (GHCR, Docker Hub, etc.)
- Deployment server with SSH access

## Quick Start

### 1. Configure GitHub Secrets

```bash
# Required secrets
STAGING_HOST=staging.example.com
STAGING_USER=ubuntu
STAGING_SSH_KEY=<private-key>

PROD_HOST=production.example.com
PROD_USER=ubuntu
PROD_SSH_KEY=<private-key>

# Optional (for Slack notifications)
SLACK_WEBHOOK_URL=<webhook-url>
```

### 2. Set up workflows

```bash
# Copy workflows to your repository
cp -r .github/workflows /path/to/your/repo/.github/

# Commit and push
git add .github/workflows
git commit -m "Add CI/CD pipeline"
git push
```

### 3. Trigger deployment

```bash
# Push to develop for staging
git push origin develop

# Push to main for production
git push origin main
```

## Workflow Configuration

### CI Workflow

Runs on every push and pull request:

```yaml
- Checkout code
- Install dependencies
- Run type checking
- Run unit tests
- Run integration tests
- Security audit (npm audit)
- Build Docker image
- Scan Docker image (Trivy)
```

### Deploy Workflow

Staging (automatic on develop):
```yaml
- Deploy to staging server
- Run database migrations
- Health check
- Notify team (optional)
```

Production (manual approval):
```yaml
- Wait for approval
- Deploy application
- Run database migrations
- Health check
- Rollback on failure
- Notify team (optional)
```

## Security Scanning

Tools configured in CI:

- **npm audit** - Dependency vulnerability scanning
- **Trivy** - Container image vulnerability scanning

Referenced but not configured in these workflows:
- **Snyk** - Can be added as an additional scanning step
- **CodeQL** - The upload-sarif action is used to import Trivy results into GitHub's security tab; CodeQL analysis itself is not configured

## Testing Locally

```bash
# Test workflows locally with act
act -j test

# Test deployment script
bash scripts/deploy.sh --dry-run
```

## Limitations

- This is a portfolio/example pipeline, not hardened for production CI/CD
- No actual uptime or bug-catch metrics exist
- Blue-green deployment is not implemented - deployment restarts containers in-place
- Adapt workflows before production use (add secrets rotation, audit logging, staging environment parity checks, etc.)

## Portfolio

This repository is part of a DevOps portfolio demonstrating CI/CD pipeline patterns for TypeScript/Docker applications.

This pipeline shows a realistic setup: lint, typecheck, tests, Docker build, vulnerability scan, staging deploy, production approval flow, healthcheck, and rollback documentation. It serves as a template that can be adapted for client projects.

## License

MIT License - feel free to use this template for your projects!

## Contributing

Contributions welcome! Please open an issue or submit a pull request.
