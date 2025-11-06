#!/bin/bash
set -euo pipefail
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting installation...${NC}"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SH_PATH="$SCRIPT_DIR/mpris_helper.sh"
JSON_PATH="$SCRIPT_DIR/mpris_helper.json"
echo -e "${BLUE}Detecting installed browsers...${NC}"
browsers=(
    "chromium google-chrome-stable google-chrome chromium"
    "chromium chromium chromium chromium"
    "brave brave-browser BraveSoftware/Brave-Browser chromium"
    "brave brave-browser-beta BraveSoftware/Brave-Browser-Beta chromium"
    "brave brave-browser-nightly BraveSoftware/Brave-Browser-Nightly chromium"
    "vivaldi vivaldi-stable vivaldi chromium"
    "vivaldi vivaldi-snapshot vivaldi-snapshot chromium"
    "edge microsoft-edge-stable microsoft-edge chromium"
    "edge microsoft-edge-beta microsoft-edge-beta chromium"
    "edge microsoft-edge-dev microsoft-edge-dev chromium"
    "opera opera opera chromium"
    "opera opera-beta opera-beta chromium"
    "opera opera-developer opera-developer chromium"
    "firefox firefox .mozilla firefox"
    "firefox librewolf .librewolf firefox"
    "firefox zen-browser .zen firefox"
)

echo -e "${BLUE}\nBuilding Native Messaging Hosts directories...${NC}"
for b in "${browsers[@]}"; do
    read -r name cmd config browsertype <<< "$b"
    if command -v "$cmd" &> /dev/null; then
        echo -e "\n${GREEN}Found: $cmd${NC}"
        if [ "$browsertype" == "chromium" ]; then
          host_dir="$HOME/.config/$config/NativeMessagingHosts"
        elif [ "$browsertype" == "firefox" ]; then
          host_dir="$HOME/$config/native-messaging-hosts"
          JSON_PATH="$SCRIPT_DIR/mpris_helper.ff.json"
        else
          continue
        fi
        update_path="$host_dir/mpris_helper.sh"
        sed_safe_host_dir=$(echo "$update_path" | sed 's/\//\\\//g')
        mkdir -p "$host_dir"
        echo -e "${BLUE}Updating mpris_helper.json path for $name:\n    \"path\": \"$update_path\"${NC}"
        sed -i "s|\"path\": \".*\"|\"path\": \"$sed_safe_host_dir\"|" "$JSON_PATH"
        cp "$JSON_PATH" "$host_dir/mpris_helper.json"
        echo -e "${GREEN}Created mpris_helper.json for $name:\n    $host_dir/mpris_helper.json${NC}"
        echo -e "${BLUE}Updating mpris_helper.sh browser=$name${NC}"
        sed -i "s|^browser=.*|browser=$name|" "$SH_PATH"
        cp "$SH_PATH" "$host_dir/mpris_helper.sh"
        echo -e "${GREEN}Created mpris_helper.sh for $name:\n    $host_dir/mpris_helper.sh${NC}"
    fi
done

# reset to blank
sed -i "s|\"path\": \".*\"|\"path\": \"blank\"|" "$SCRIPT_DIR/mpris_helper.json"
sed -i "s|\"path\": \".*\"|\"path\": \"blank\"|" "$SCRIPT_DIR/mpris_helper.ff.json"
sed -i "s|^browser=.*|browser=blank|" "$SH_PATH"
