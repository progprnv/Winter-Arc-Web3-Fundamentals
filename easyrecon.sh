#!/bin/bash

# easyrecon.sh - Automated Subdomain Enumeration & JS Analysis Workflow
# Supports:
#   Single Domain Mode: ./easyrecon.sh -d example.com
#   Multi Domain Mode : ./easyrecon.sh -f target.txt

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

usage() {
    echo -e "${YELLOW}Usage:${RESET}"
    echo -e "  $0 -d <domain>     # Single domain mode"
    echo -e "  $0 -f <file>       # Multi domain mode"
    exit 1
}

# Recon function for one domain
run_recon() {
    domain=$1
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    # Create separate folder for each root domain with timestamped subfolder
    output_dir="$(pwd)/${domain}/recon_${timestamp}"

    mkdir -p "$output_dir"

    echo -e "${GREEN}[+] Starting Recon for $domain${RESET}"

    # ------------------------
    # Subdomain Enumeration
    # ------------------------
    echo -e "${YELLOW}[+] Running Subfinder...${RESET}"
    subfinder -d "$domain" -recursive -all -silent > "$output_dir/subfinder.txt"

    echo -e "${YELLOW}[+] Running Findomain...${RESET}"
    findomain -t "$domain" -q > "$output_dir/findomain.txt"

    echo -e "${YELLOW}[+] Running Subdominator...${RESET}"
    subdominator -d "$domain" | grep -E '^[a-zA-Z0-9.-]+\.[a-z]{2,}$' > "$output_dir/subdominator.txt"

    echo -e "${YELLOW}[+] Running Amass...${RESET}"
    amass enum -brute -passive -d "$domain" -silent > "$output_dir/amass.txt"

    echo -e "${YELLOW}[+] Running Knockpy...${RESET}"
    knockpy "$domain" --no-http-status > "$output_dir/knockpy_raw.txt"
    grep -E '^[a-zA-Z0-9.-]+\.[a-z]{2,}$' "$output_dir/knockpy_raw.txt" | sort -u > "$output_dir/knockpy.txt"

    # Combine and clean subdomains
    cat "$output_dir"/{subfinder.txt,findomain.txt,subdominator.txt,amass.txt,knockpy.txt} \
        | grep -E '^[a-zA-Z0-9.-]+\.[a-z]{2,}$' \
        | sort -u > "$output_dir/subdomains.txt"

    echo -e "${GREEN}[+] Subdomain enumeration completed for $domain!${RESET}"

    # ------------------------
    # URL Collection
    # ------------------------
    echo -e "${YELLOW}[+] Running Waymore...${RESET}"
    waymore -i "$domain" -mode U -oU "$output_dir/waymore_urls.txt"

    echo -e "${YELLOW}[+] Running Katana...${RESET}"
    katana -u "$output_dir/subdomains.txt" -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -kf -jc -fx \
          -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg -o "$output_dir/katana_urls.txt"

    echo -e "${YELLOW}[+] Running Waybackurls...${RESET}"
    cat "$output_dir/subdomains.txt" | waybackurls > "$output_dir/waybackurls.txt"

    # Combine URLs
    cat "$output_dir"/{waymore_urls.txt,katana_urls.txt,waybackurls.txt} | sort -u > "$output_dir/endpoints.txt"
    echo -e "${GREEN}[+] Endpoints saved in $output_dir/endpoints.txt${RESET}"

    # ------------------------
    # JavaScript Extraction
    # ------------------------
    echo -e "${YELLOW}[+] Extracting JavaScript files...${RESET}"
    grep "\.js" "$output_dir/endpoints.txt" | sort -u > "$output_dir/js.txt"
    echo -e "${GREEN}[+] JavaScript files saved in $output_dir/js.txt${RESET}"

    echo -e "${GREEN}[+] Recon completed for $domain${RESET}"
}

# ------------------------
# Parse arguments
# ------------------------
if [ $# -eq 0 ]; then
    usage
fi

while getopts ":d:f:" opt; do
    case $opt in
        d)  # Single domain mode
            run_recon "$OPTARG"
            exit 0
            ;;
        f)  # Multi-domain mode
            target_file=$OPTARG
            if [ ! -f "$target_file" ]; then
                echo -e "${RED}[!] File not found: $target_file${RESET}"
                exit 1
            fi
            while IFS= read -r domain || [ -n "$domain" ]; do
                if [[ -z "$domain" || "$domain" =~ ^# ]]; then
                    continue
                fi
                run_recon "$domain"
            done < "$target_file"
            exit 0
            ;;
        *)
            usage
            ;;
    esac
done