# Security

## CI/CD Security
This repository shows an example GitHub Actions pipeline. Before using in production:

1. Pin all third-party actions to full commit SHAs (not version tags)
2. Use GitHub Environments with required reviewers for production
3. Restrict GITHUB_TOKEN permissions to minimum needed
4. Never store secrets in workflow files or code
5. Rotate deployment SSH keys regularly
6. Use OIDC instead of long-lived credentials where possible
7. Review Dependabot alerts regularly

## Pipeline Security
- npm audit is run as part of CI (moderate severity and above)
- Trivy scans Docker images for container vulnerabilities
- SARIF results can be uploaded to GitHub Security tab
- Production deployment requires manual approval via GitHub Environments
