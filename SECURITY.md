# Security Policy

## Supported Versions

Only the latest `main` branch is currently supported for security updates.

## Reporting a Vulnerability

We take the security of our AI integration scripts seriously. If you find a security vulnerability, please do NOT use the public issue tracker.

Instead, please report it via the following process:
1. Email: **security@your-org-domain.com** (replace with actual security email)
2. Provide a detailed description of the vulnerability.
3. Include steps to reproduce the issue.

We will acknowledge your report within 48 hours and provide a timeline for a fix.

### AI-Specific Security
Please be cautious when integrating LLMs. Ensure:
- API keys are NEVER committed to the repository (use `.env` and `.gitignore`).
- LLM outputs are validated before execution in production environments.
- Prompt injection protection is considered in all AI-driven scripts.
