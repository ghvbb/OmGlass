#!/bin/bash

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

OMGLASS_DIR="OmGlass"
TARGET_DIR="$HOME/.config"
CORE_APPS=("python" "python-gobject" "gtk4" "gtk3" "python-pip" "tty-clock" "cmatrix" "cava" "snapshot")
FOLDERS_REQUIRED=("hypr" "waybar" "walker")

clear
echo -e "${CYAN}${BOLD}==========================================${NC}"
echo -e "${CYAN}${BOLD}       Omarchy & OmGlass Manager          ${NC}"
echo -e "${CYAN}${BOLD}==========================================${NC}"
echo ""

echo -e "${BOLD}Do You Want To :${NC}"
echo -e "${GREEN}1)${NC} Install OmGlass"
echo -e "${BLUE}2)${NC} Update Omarchy"
echo -e "${PURPLE}3)${NC} Upgrade OmGlass"
echo -ne "\n${BOLD}Select an option (1-3): ${NC}"
read -r main_choice

case $main_choice in
    1) ACTION="Installing OmGlass" ;;
    2) ACTION="Updating Omarchy" ;;
    3) ACTION="Upgrading OmGlass" ;;
    *) echo -e "${RED}Invalid option. Exiting.${NC}"; exit 1 ;;
esac

echo -e "\n${BLUE}>> Proceeding with: $ACTION...${NC}"
sleep 1

if ! command -v yay &> /dev/null; then
    echo -e "${RED}${BOLD}[!] Error: 'yay' is not installed.${NC}"
    exit 1
fi

if [ -d "$OMGLASS_DIR" ]; then
    cd "$OMGLASS_DIR" || exit
fi

BACKUP_ENABLED="no"
if [[ "$main_choice" == "1" || "$main_choice" == "3" ]]; then
    echo -e "\n${RED}${BOLD}Warning !${NC}"
    echo -e "${YELLOW}Your Files Will Be BackUp${NC}"
    echo -ne "${BOLD}do you want (yes/no): ${NC}"
    read -r backup_ans
    if [[ "$backup_ans" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        BACKUP_ENABLED="yes"
    fi
fi

echo -e "\n${PURPLE}${BOLD}[1/2] Syncing Configurations...${NC}"
mkdir -p "$HOME/.local/share/applications"

for folder in "${FOLDERS_REQUIRED[@]}"; do
    if [ "$BACKUP_ENABLED" == "yes" ]; then
        if [ -d "$TARGET_DIR/$folder" ]; then
            echo -e "${YELLOW}>> Backing up existing $folder to $folder.bak${NC}"
            rm -rf "$TARGET_DIR/${folder}.bak"
            mv "$TARGET_DIR/$folder" "$TARGET_DIR/${folder}.bak"
        fi
    fi

    if [ -d "$folder" ]; then
        cp -r "$folder" "$TARGET_DIR/"
        echo -e "${GREEN}[+] Synced $folder${NC}"
    fi
done

echo -e ""
echo -ne "${BOLD}Do you want to install app settings? (y/n): ${NC}"
read -r app_confirm

if [[ "$app_confirm" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\n${PURPLE}${BOLD}[2/2] Installing Dependencies & GUI${NC}"
    yay -S --needed --noconfirm "${CORE_APPS[@]}"
    
    if [ -f "omarchy-control.py" ]; then
        cp omarchy-control.py "$HOME/.config/hypr/"
        chmod +x "$HOME/.config/hypr/omarchy-control.py"
        
        cat <<EOF > "$HOME/.local/share/applications/omarchy-settings.desktop"
[Desktop Entry]
Type=Application
Name=Omarchy Settings
Comment=Configuration Manager
Exec=python3 $HOME/.config/hypr/omarchy-control.py
Icon=preferences-system
Categories=Settings;System;
Terminal=false
EOF
        update-desktop-database "$HOME/.local/share/applications" &> /dev/null
        echo -e "${GREEN}[+] App settings installed successfully.${NC}"
    fi
else
    echo -e "${RED}Skipping app settings.${NC}"
fi

echo -e "\n${CYAN}${BOLD}==========================================${NC}"
echo -e "${GREEN}${BOLD}             PROCESS COMPLETE             ${NC}"
echo -e "${CYAN}${BOLD}==========================================${NC}"
echo ""
echo -ne "${YELLOW}${BOLD}Would you like to reboot now? (y/n): ${NC}"
read -r reboot_answer

if [[ "$reboot_answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${RED}Rebooting...${NC}"
    sleep 2
    reboot
else
    echo -e "${GREEN}Finished! Please restart your session.${NC}"
fi
