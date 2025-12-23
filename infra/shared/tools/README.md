# WordPress Vulnerability Scanning Tools

This directory contains tools for scanning your WordPress installation for known vulnerabilities in plugins, themes, and WordPress core.

## Tools Included

1. **WPScan** - Industry-standard WordPress vulnerability scanner
2. **scan-vulnerabilities.ps1** - PowerShell script to run vulnerability checks

## Prerequisites

- Podman and podman-compose installed
- WordPress containers running (dev or prod environment)

## Quick Start

### Option 1: Using WPScan Docker Service

Run a basic vulnerability scan against your dev environment:

```powershell
cd infra/shared/tools
podman-compose up wpscan
```

This will scan `http://wordpress:8080` (your dev WordPress instance) for:
- WordPress core vulnerabilities
- Plugin vulnerabilities
- Theme vulnerabilities
- Insecure configurations

### Option 2: Using PowerShell Script

```powershell
cd infra/shared/tools
.\scan-vulnerabilities.ps1 -Environment dev
```

Options:
- `-Environment dev` - Scan development environment (default)
- `-Environment prod` - Scan production environment
- `-Verbose` - Show detailed output

## WPScan Free Tier

WPScan offers a free tier with:
- 25 API requests per day
- Basic vulnerability database access
- Core, plugin, and theme vulnerability checks

For unlimited scans and priority support, visit: https://wpscan.com/pricing

### Getting an API Token (Optional but Recommended)

1. Register at https://wpscan.com/register
2. Get your free API token from https://wpscan.com/profile
3. Add to your environment or pass via command line:

```powershell
# Set in environment
$env:WPSCAN_API_TOKEN="your_api_token_here"

# Or pass directly
podman-compose run wpscan --url http://wordpress --api-token your_api_token_here
```

## Manual WPScan Commands

Scan specific URL:
```powershell
podman-compose run wpscan --url http://wordpress:8080
```

Enumerate plugins only:
```powershell
podman-compose run wpscan --url http://wordpress:8080 --enumerate p
```

Enumerate themes only:
```powershell
podman-compose run wpscan --url http://wordpress:8080 --enumerate t
```

Enumerate users:
```powershell
podman-compose run wpscan --url http://wordpress:8080 --enumerate u
```

Full aggressive scan:
```powershell
podman-compose run wpscan --url http://wordpress:8080 --enumerate ap,at,u --plugins-detection aggressive
```

## Output

Scan results are saved to `./reports/` directory with timestamps:
- `wpscan-YYYYMMDD-HHMMSS.txt` - Full scan output
- `wpscan-latest.txt` - Most recent scan (symlink)

## Interpreting Results

WPScan will report:
- **[!] Critical** - Requires immediate attention
- **[+] Informational** - Useful findings
- **[i] Info** - General information

### Common Findings

1. **Outdated WordPress version** - Update WordPress core
2. **Vulnerable plugins** - Update or remove affected plugins
3. **Vulnerable themes** - Update or replace themes
4. **Username enumeration** - Consider disabling author archives
5. **Directory listing** - Already disabled in .htaccess
6. **XML-RPC enabled** - May want to disable if not needed

## Security Best Practices

After running scans:
1. Update all flagged plugins/themes immediately
2. Remove unused plugins/themes
3. Review and implement security recommendations
4. Run scans regularly (weekly for production)
5. Subscribe to WordPress security mailing lists

## Troubleshooting

**"Connection refused"**
- Ensure WordPress containers are running: `podman ps`
- Check network connectivity between containers

**"Rate limit exceeded"**
- You've hit the free tier limit (25/day)
- Wait 24 hours or upgrade to paid plan
- Use `--no-update` flag to skip database updates

**"SSL certificate problem"**
- For local testing, use `--disable-tls-checks`
- Not recommended for production scans

## Additional Resources

- WPScan documentation: https://github.com/wpscanteam/wpscan
- WordPress security guide: https://wordpress.org/support/article/hardening-wordpress/
- WPVulnDB: https://wpscan.com/
