# GitHub Actions CI/CD Pipeline Architecture

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│                                                              │
│  Push to main/develop                                       │
│         │                                                    │
│         ▼                                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              CI Workflow (ci.yml)                     │  │
│  │  ├─ Checkout code                                    │  │
│  │  ├─ Setup Node.js 20                                │  │
│  │  ├─ Install dependencies                            │  │
│  │  ├─ Type checking (TypeScript)                      │  │
│  │  ├─ Linting                                         │  │
│  │  ├─ Unit tests                                      │  │
│  │  ├─ Integration tests                               │  │
│  │  ├─ Security audit (npm audit)                      │  │
│  │  ├─ Build application                               │  │
│  │  ├─ Build Docker image                              │  │
│  │  └─ Scan Docker image (Trivy)                       │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                            │
│                 ▼                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  If develop branch:                                  │  │
│  │  Deploy Staging (deploy-staging.yml)                │  │
│  │  ├─ SSH to staging server                           │  │
│  │  ├─ Pull latest code                                │  │
│  │  ├─ Pull Docker image                               │  │
│  │  ├─ Start containers                                │  │
│  │  ├─ Run migrations                                  │  │
│  │  └─ Health check                                    │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                            │
│                 ▼                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  If main branch:                                     │  │
│  │  Deploy Production (deploy-production.yml)          │  │
│  │  ├─ Request manual approval                         │  │
│  │  ├─ SSH to production server                        │  │
│  │  ├─ Create backup                                   │  │
│  │  ├─ Pull latest code                                │  │
│  │  ├─ Blue-green deployment                           │  │
│  │  ├─ Run migrations                                  │  │
│  │  ├─ Health check                                    │  │
│  │  └─ Rollback on failure                             │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                            │
│                 ▼                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Notifications                                       │  │
│  │  ├─ Slack notification (success/failure)            │  │
│  │  └─ GitHub status check                             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Details

### CI Workflow (ci.yml)

**Triggers**:
- Push to main or develop
- Pull requests to main or develop
- Manual trigger (workflow_dispatch)

**Jobs**:

1. **Test Job**
   - Runs on: ubuntu-latest
   - Services: PostgreSQL 15, Redis 7
   - Steps:
     - Checkout code
     - Setup Node.js 20
     - Install dependencies
     - Type checking
     - Linting
     - Unit tests
     - Integration tests
     - Security audit
     - Build application

2. **Build Job**
   - Depends on: test job
   - Runs on: ubuntu-latest
   - Steps:
     - Setup Docker Buildx
     - Login to GHCR
     - Build and push Docker image
     - Scan image with Trivy
     - Upload SARIF results

3. **Notify Job**
   - Depends on: test and build jobs
   - Runs on: ubuntu-latest
   - Steps:
     - Determine status
     - Notify Slack

### Staging Deployment (deploy-staging.yml)

**Triggers**:
- CI workflow completion on develop branch
- Manual trigger (workflow_dispatch)

**Environment**: staging

**Steps**:
1. Checkout develop branch
2. SSH to staging server
3. Pull latest code
4. Login to Docker registry
5. Pull latest Docker image
6. Start containers
7. Run database migrations
8. Health check (30 retries, 2s interval)
9. Notify Slack

### Production Deployment (deploy-production.yml)

**Triggers**:
- CI workflow completion on main branch
- Manual trigger (workflow_dispatch)

**Environment**: production

**Steps**:
1. Checkout main branch
2. Request manual approval
3. SSH to production server
4. Create database backup
5. Pull latest code
6. Login to Docker registry
7. Blue-green deployment
8. Run database migrations
9. Health check (30 retries, 2s interval)
10. Verify deployment
11. Notify Slack
12. Rollback on failure

## Environment Configuration

### GitHub Secrets Required

**For CI**:
- `GITHUB_TOKEN` (automatic)

**For Staging**:
- `STAGING_HOST` - Staging server IP/hostname
- `STAGING_USER` - SSH username (usually ubuntu)
- `STAGING_SSH_KEY` - Private SSH key

**For Production**:
- `PROD_HOST` - Production server IP/hostname
- `PROD_USER` - SSH username (usually ubuntu)
- `PROD_SSH_KEY` - Private SSH key
- `APPROVERS` - GitHub usernames for approval

**For Notifications**:
- `SLACK_WEBHOOK_URL` - Slack webhook for notifications

### Environment Variables

**Staging**:
```
DATABASE_URL=postgresql://user:pass@postgres:5432/db
REDIS_URL=redis://redis:6379
NODE_ENV=staging
```

**Production**:
```
DATABASE_URL=postgresql://user:pass@postgres:5432/db
REDIS_URL=redis://redis:6379
NODE_ENV=production
```

## Security Considerations

### Secrets Management
- All sensitive data stored in GitHub Secrets
- SSH keys encrypted
- Database credentials never in code
- Tokens rotated regularly

### Access Control
- Production deployment requires manual approval
- Separate staging and production environments
- SSH key-based authentication only
- Audit logs for all deployments

### Code Security
- SAST scanning (CodeQL)
- Dependency scanning (npm audit)
- Container scanning (Trivy)
- No hardcoded credentials

## Performance Metrics

### Build Times
- CI: ~5-10 minutes
- Docker build: ~3-5 minutes
- Tests: ~2-3 minutes
- Total: ~10-15 minutes

### Deployment Times
- Staging: ~5 minutes
- Production: ~10 minutes (including approval)

### Success Rate
- Target: 95%+
- Rollback time: < 5 minutes

## Monitoring & Alerts

### Slack Notifications
- CI success/failure
- Staging deployment status
- Production deployment status
- Rollback alerts

### GitHub Status Checks
- Required for PR merge
- Shows test results
- Shows build status

### Logs
- GitHub Actions logs (7 days retention)
- Server deployment logs
- Application logs (CloudWatch/ELK)

## Troubleshooting

### Common Issues

**Issue**: Tests fail locally but pass in CI
- Solution: Check Node.js version, dependencies, environment variables

**Issue**: Docker image build fails
- Solution: Check Dockerfile, dependencies, registry credentials

**Issue**: Deployment fails with SSH error
- Solution: Verify SSH key, host IP, firewall rules

**Issue**: Health check timeout
- Solution: Check application startup time, database connectivity

### Debug Commands

```bash
# View workflow logs
gh run view <run-id> --log

# List recent runs
gh run list --branch main

# Trigger workflow manually
gh workflow run ci.yml --ref main

# Check deployment status
ssh user@host "docker compose ps"
```

## Best Practices

### Code Quality
- ✅ All tests must pass before merge
- ✅ Code coverage > 80%
- ✅ No security vulnerabilities
- ✅ Linting passes

### Deployment
- ✅ Always deploy to staging first
- ✅ Manual approval for production
- ✅ Automated rollback on failure
- ✅ Health checks after deployment

### Monitoring
- ✅ Slack notifications for all deployments
- ✅ Automated health checks
- ✅ Database backups before deployment
- ✅ Audit logs for all changes

## Scaling Considerations

### Parallel Jobs
- Multiple test jobs for different test suites
- Parallel Docker builds for different architectures
- Matrix strategy for multiple Node.js versions

### Self-Hosted Runners
- Use for production deployments
- Better performance and security
- Custom environment setup

### Caching
- npm dependencies cache
- Docker layer caching
- Build artifacts cache

## Cost Optimization

### GitHub Actions
- Free tier: 2,000 minutes/month
- Paid: $0.008 per minute
- Self-hosted runners: Free

### Docker Registry
- GHCR: Free for public repos
- Private repos: $5/month

### Infrastructure
- Staging: t4g.micro (~$6/month)
- Production: t4g.small (~$12/month)

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Workflows](https://docs.github.com/en/actions/using-workflows)
- [Docker Build Action](https://github.com/docker/build-push-action)
- [SSH Action](https://github.com/appleboy/ssh-action)
- [Slack GitHub Action](https://github.com/slackapi/slack-github-action)
