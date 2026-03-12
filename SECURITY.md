# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in AI Night Shift, please report it responsibly:

1. **Do NOT open a public issue**
2. Email: **security@judyailab.com**
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will acknowledge your report within 48 hours and aim to release a fix within 7 days for critical issues.

## Security Considerations

### Permission Modes

AI Night Shift can run AI agents with varying permission levels:

- **Default (recommended):** `SKIP_PERMISSIONS=false` — Claude Code runs with its standard permission model, prompting for approval on file writes and shell commands.
- **Autonomous mode:** `SKIP_PERMISSIONS=true` — grants the AI unrestricted access to your filesystem and shell. **Only use this on isolated machines or when you fully understand the risks.**

### Best Practices

- Run night shifts on **dedicated machines or VMs**, not on production servers
- Use a **dedicated user account** with minimal privileges
- Keep **API keys in `config.env`** (gitignored), never in scripts
- Review **morning reports** to audit what the AI did overnight
- Enable **backup plugin** to snapshot critical files before each shift
- Set appropriate **file permissions** (`chmod 600 config.env`)

### Known Risks

- AI agents with autonomous permissions can execute arbitrary shell commands
- Rate limit handling involves sleep periods during which the process remains active
- Plugin scripts run with the same permissions as the main process

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |
