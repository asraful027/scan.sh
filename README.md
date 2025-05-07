Project Setup


mkdir recon_tool
cd recon_tool

# Create the scan script
nano scan.sh

# Paste the improved scan.sh content (from above)
chmod +x scan.sh

# Create the scan library
nano scan.lib

# Paste the scan.lib content (from above)
chmod +x scan.lib



----------------------------------------------------------------------------------------------
 
 
 Expectations for scan.lib
Your scan.lib file should define functions like:

nmap_scan()

dirsearch_scan()

crt_scan()

Each should accept:
nmap_scan <domain> <directory>, and save output in:

$directory/nmap

$directory/dirsearch

$directory/crt



------------------------------

Ensure These Tools Are Installed:
nmap

dirsearch or ffuf

jq (used in report_domain for parsing crt.sh JSON)

-------------------------------------

You can install most of them via:

sudo apt install nmap jq
-----------------------------------------
