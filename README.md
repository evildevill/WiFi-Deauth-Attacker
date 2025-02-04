## WiFi-Deauth-Attacker

### Description

WiFi-Deauth-Attacker is an automated Bash script that scans for nearby Wi-Fi networks and their connected devices, then performs a deauthentication (deauth) attack using `aireplay-ng`. This script is designed for educational purposes and authorized penetration testing only.

### Features

- Automatically detects your wireless interface.
- Enables monitor mode for packet injection.
- Scans for available Wi-Fi networks and connected clients.
- Performs mass deauthentication attacks on selected networks or clients.
- Fully automated process with minimal user input.

### Prerequisites

- A Linux system (preferably Kali Linux or Parrot OS).
- A wireless adapter that supports monitor mode and packet injection.
- Installed dependencies:
```bash
sudo apt update && sudo apt install aircrack-ng
```

### Usage

- Clone the repository:
```bash
git clone https://github.com/your-username/WiFi-Deauth-Attacker.git
cd WiFi-Deauth-Attacker
```

- Give execute permission:
```bash
chmod +x deauth.sh
```
- Run the script as root:
```bash
sudo ./deauth.sh
```
- Follow the on-screen instructions to scan and select targets.

### Disclaimer

This script is intended for educational purposes only. Unauthorized use of this script on networks you do not own or have explicit permission to test is illegal and punishable by law. The developers are not responsible for any misuse.

#### License

MIT License. See [LICENSE](LICENSE) file for details.

Author: **Waseem Akram**

Website: [Blog & Portfolio](https://hackerwasii.com)
