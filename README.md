# Automatically log into your opnsense:captiveportal
## Installation
🔥 Install instructions for Termux 🔥
```bash
pkg update && pkg upgrade -y && pkg install git jq -y && git clone https://github.com/Fazz6123/autologin-opnsense.git && mv autologin-opnsense/autologin.sh ~ && rm -r -f autologin-opnsense/ && nano autologin.sh
```

Run the script 
```bash
bash autologin.sh
```