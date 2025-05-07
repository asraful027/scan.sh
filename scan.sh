#!/bin/bash

source ./scan.lib

# Default values
MODE=""
INTERACTIVE=false

# Parse options
while getopts "m:i" OPTION; do
  case $OPTION in
    m) MODE=$OPTARG ;;
    i) INTERACTIVE=true ;;
    *) echo "Usage: $0 [-m mode] [-i] [domains...]"; exit 1 ;;
  esac
done

# Run scans based on selected mode
scan_domain() {
  DOMAIN="$1"
  DIRECTORY="${DOMAIN}_recon"

  echo "Creating directory: $DIRECTORY"
  mkdir -p "$DIRECTORY"

  case "$MODE" in
    nmap-only)      nmap_scan "$DOMAIN" "$DIRECTORY" ;;
    dirsearch-only) dirsearch_scan "$DOMAIN" "$DIRECTORY" ;;
    crt-only)       crt_scan "$DOMAIN" "$DIRECTORY" ;;
    *)              nmap_scan "$DOMAIN" "$DIRECTORY"
                    dirsearch_scan "$DOMAIN" "$DIRECTORY"
                    crt_scan "$DOMAIN" "$DIRECTORY" ;;
  esac
}

# Generate a combined recon report
report_domain() {
  DOMAIN="$1"
  DIRECTORY="${DOMAIN}_recon"
  REPORT="$DIRECTORY/report"
  TODAY=$(date)

  echo "Generating recon report for $DOMAIN..."
  {
    echo "Recon report for $DOMAIN"
    echo "Scan date: $TODAY"
    echo ""
    if [[ -f "$DIRECTORY/nmap" ]]; then
      echo "=== Nmap Results ==="
      grep -E "^\s*\S+\s+\S+\s+\S+\s*$" "$DIRECTORY/nmap"
      echo ""
    fi
    if [[ -f "$DIRECTORY/dirsearch" ]]; then
      echo "=== Dirsearch Results ==="
      cat "$DIRECTORY/dirsearch"
      echo ""
    fi
    if [[ -f "$DIRECTORY/crt" ]]; then
      echo "=== crt.sh Results ==="
      jq -r ".[] | .name_value" "$DIRECTORY/crt"
      echo ""
    fi
  } > "$REPORT"

  echo "Report saved to $REPORT"
}

# Main interactive or batch mode
if $INTERACTIVE; then
  while true; do
    echo -n "Enter a domain (or type 'quit' to exit): "
    read -r INPUT
    [[ "$INPUT" == "quit" ]] && break
    scan_domain "$INPUT"
    report_domain "$INPUT"
  done
else
  for DOMAIN in "${@:$OPTIND}"; do
    scan_domain "$DOMAIN"
    report_domain "$DOMAIN"
  done
fi
