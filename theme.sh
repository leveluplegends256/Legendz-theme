#!/bin/bash
# -------------------------
# Color Definitions
# -------------------------
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
RESET='\e[0m'
# -------------------------
# Animate Logo
# -------------------------
animate_logo() {
    clear
    local logo=(
        "██╗     ███████╗██╗   ██╗███████╗██╗     ██╗   ██╗██████╗ ██╗     ███████╗ ██████╗ ███████╗███╗   ██╗██████╗ ███████╗"
"██║     ██╔════╝██║   ██║██╔════╝██║     ██║   ██║██╔══██╗██║     ██╔════╝██╔════╝ ██╔════╝████╗  ██║██╔══██╗╚══███╔╝"
"██║     █████╗  ██║   ██║█████╗  ██║     ██║   ██║██████╔╝██║     █████╗  ██║  ███╗█████╗  ██╔██╗ ██║██║  ██║  ███╔╝ "
"██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██║     ██╔══╝  ██║   ██║██╔══╝  ██║╚██╗██║██║  ██║ ███╔╝  "
"███████╗███████╗ ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ███████╗███████╗╚██████╔╝███████╗██║ ╚████║██████╔╝███████╗"
"╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚══════╝  ╚═════╝  ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝"
    )
    for line in "${logo[@]}"; do
        echo -e "${CYAN}${line}${RESET}"
        sleep 0.1
    done
    echo ""
}
# -------------------------
# Functions
# -------------------------
check_node() {
    if ! command -v node >/dev/null 2>&1; then
        echo -e "${YELLOW}Node.js not found. Installing Node.js 20.x...${RESET}"
        curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt install -y nodejs
    else
        echo -e "${GREEN}Node.js is already installed.${RESET}"
    fi
}
install_yarn() {
    if ! command -v yarn >/dev/null 2>&1; then
        echo -e "${YELLOW}Yarn not found. Installing Yarn...${RESET}"
        npm install --global yarn
    else
        echo -e "${GREEN}Yarn is already installed.${RESET}"
    fi
}
create_backup() {
    PANEL_DIR="/var/www/pterodactyl"
    cd "$PANEL_DIR" || { echo -e "${RED}Panel directory not found!${RESET}"; return; }
    BACKUP_NAME="backup_$(date +%Y%m%d%H%M%S).tar.gz"
    tar -czf "$BACKUP_NAME" ./
    echo -e "${GREEN}Backup created: $BACKUP_NAME${RESET}"
}
apply_theme() {
    echo -ne "${YELLOW}Do you want to create a backup before applying the theme? (y/N): ${RESET}"
    read create
    if [[ "$create" =~ ^[Yy]$ ]]; then
        create_backup
    fi
    echo -ne "${YELLOW}Enter the full URL of your theme zip: ${RESET}"
    read THEME_URL
    TEMP_ZIP="/tmp/panel_theme.zip"
    echo -e "${CYAN}Downloading theme...${RESET}"
    if ! curl -L -o "$TEMP_ZIP" "$THEME_URL"; then
        echo -e "${RED}Failed to download theme. Check URL.${RESET}"
        return
    fi
    echo -e "${CYAN}Extracting theme...${RESET}"
    unzip -o "$TEMP_ZIP" -d /tmp/panel_theme > /dev/null 2>&1 || {
        echo -e "${RED}Error extracting zip. Make sure it contains 'resources' and 'tailwind.config.js'.${RESET}"
        return
    }
    PANEL_DIR="/var/www/pterodactyl"
    echo -e "${CYAN}Copying theme files to panel directory...${RESET}"
    cp -r /tmp/panel_theme/* "$PANEL_DIR/" 2>/dev/null || {
        echo -e "${RED}Failed to copy theme files. Check permissions and panel path.${RESET}"
        return
    }
    echo -e "${CYAN}Checking Node.js and Yarn...${RESET}"
    check_node
    install_yarn
    echo -e "${CYAN}Installing panel dependencies...${RESET}"
    cd "$PANEL_DIR" || { echo -e "${RED}Panel directory not found!${RESET}"; return; }
    yarn install
    echo -e "${CYAN}Building panel for production...${RESET}"
    export NODE_OPTIONS=--openssl-legacy-provider
    yarn build:production
    echo -e "${CYAN}Clearing Laravel compiled views...${RESET}"
    php artisan view:clear
    echo -e "${GREEN}Theme applied successfully!${RESET}"
}
restore_backup() {
    PANEL_DIR="/var/www/pterodactyl"
    cd "$PANEL_DIR" || { echo -e "${RED}Panel directory not found!${RESET}"; return; }
    BACKUP_FILE=$(ls -t backup_* 2>/dev/null | head -n1)
    if [[ -z "$BACKUP_FILE" ]]; then
        echo -e "${RED}No backup found!${RESET}"
        return
    fi
    echo -ne "${YELLOW}Restoring backup: $BACKUP_FILE will overwrite current theme. Continue? (y/N): ${RESET}"
    read confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Restore cancelled.${RESET}"
        return
    fi
    tar -xzf "$BACKUP_FILE" -C "$PANEL_DIR" || {
        echo -e "${RED}Failed to restore backup.${RESET}"
        return
    }
    echo -e "${GREEN}Backup restored successfully!${RESET}"
}
create_vps() {
    echo -e "${CYAN}WATCH THE VIDEO FOR SETUP: https://youtu.be/FH5AI8G2W5o?si=fhXJg0iJx80MAi1m${RESET}"
    bash <(curl -s https://vps1.jishnu.fun)
}
# -------------------------
# Main Menu
# -------------------------
while true; do
    animate_logo
    echo -e "${YELLOW}Select an option:${RESET}"
    echo -e "${GREEN}1) Apply Theme${RESET}"
    echo -e "${BLUE}2) Restore Backup${RESET}"
    echo -e "${CYAN}3) Create VPS (credits-Youtube:@JishnuTech69)${RESET}"
    echo -e "${RED}4) Exit${RESET}"
    echo -ne "${YELLOW}Enter your choice (1-4): ${RESET}"
    read choice
    case $choice in
        1) 
            apply_theme 
            ;;
        2) 
            restore_backup 
            ;;
        3) 
            create_vps 
            ;;
        4) 
            echo -e "${RED}Exiting...${RESET}" 
            exit 0 
            ;;
        *) echo -e "${RED}Invalid choice!${RESET}" ;;
    esac
    echo -e "\nPress enter to continue..."
    read
done
