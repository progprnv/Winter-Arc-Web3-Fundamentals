# EasyRecon - Automated Subdomain Enumeration & JS Analysis

A comprehensive bash script for automated reconnaissance that performs subdomain enumeration and JavaScript analysis for web application security testing.

## Features

- **Single Domain Mode**: Analyze a single domain
- **Multi Domain Mode**: Process multiple domains from a file
- **Organized Output**: Each root domain gets its own directory with timestamped subfolders
- **Comprehensive Enumeration**: Uses multiple tools including Subfinder, Findomain, Subdominator, Amass, and Knockpy
- **URL Collection**: Gathers URLs using Waymore, Katana, and Waybackurls
- **JavaScript Extraction**: Automatically extracts JavaScript file URLs for further analysis

## Usage

### Single Domain Mode
```bash
./easyrecon.sh -d example.com
```

### Multi Domain Mode
```bash
./easyrecon.sh -f target.txt
```

## Output Structure

When using the multi-domain mode with a `target.txt` file containing different root domains, the script creates separate folders for each domain:

```
├── example.com/
│   ├── recon_2025-09-17_06-44-59/
│   │   ├── subfinder.txt
│   │   ├── findomain.txt
│   │   ├── subdomains.txt
│   │   ├── endpoints.txt
│   │   ├── js.txt
│   │   └── ...
│   └── recon_2025-09-17_08-30-15/  # Additional runs
├── google.com/
│   └── recon_2025-09-17_06-44-59/
└── github.com/
    └── recon_2025-09-17_06-44-59/
```

## Target File Format

The `target.txt` file should contain one domain per line:

```
example.com
google.com
github.com
# Comments are supported and will be ignored
stackoverflow.com

# Empty lines are also ignored
microsoft.com
```

## Required Tools

The script uses the following tools (install them as needed):
- `subfinder`
- `findomain`
- `subdominator`
- `amass`
- `knockpy`
- `waymore`
- `katana`
- `waybackurls`

## Key Enhancement

**Separate Folders for Different Root Domains**: Unlike traditional scripts that create unique folders for each run, this enhanced version organizes output by root domain, with timestamped subfolders for each reconnaissance run. This makes it easier to:

- Track reconnaissance history for specific domains
- Compare results across different time periods
- Organize findings by target organization
- Maintain clean directory structures for large-scale assessments

## Script Permissions

Make sure the script has execute permissions:
```bash
chmod +x easyrecon.sh
```