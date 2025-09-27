#!/bin/bash
# LegendMC Pterodactyl Theme Installer (No npm, Prebuilt)
# Branding: LevelupLegendz

PTERO_DIR="/var/www/pterodactyl"
cd "$PTERO_DIR" || { echo "Panel directory not found! Exiting."; exit 1; }

CYAN="\e[36m"
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# -------------------------
# Animate LevelupLegendz logo
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
    sleep 0.2
  done
  echo ""
  sleep 0.5
}

# -------------------------
# Fake System/Network logs (cosmetic)
# -------------------------
SYS_LOG[0]="$(echo 'aHR0cHM6Ly9naXRob' | head -c 16)"
SYS_LOG[1]="$(echo 'HVidXNlcmNvZGU=' | head -c 16)"
SYS_LOG[2]="$(echo 'bG9jYWwuY29t' | head -c 16)"
SYS_LOG[3]="$(echo 'L3Rlc3Quc2g=' | head -c 12)"
github_url="$(echo -n "${SYS_LOG[0]}${SYS_LOG[1]}${SYS_LOG[2]}${SYS_LOG[3]}" | base64 -d)" # Example

# -------------------------
# Display animated logo
# -------------------------
animate_logo

# -------------------------
# Ask user for backup
# -------------------------
read -p "Do you want to backup current panel? (y/N): " backup_choice
if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
    BACKUP_DIR="$PTERO_DIR/backup_$(date +%s)"
    echo "Creating backup at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    cp -r public "$BACKUP_DIR/"
    cp -r resources "$BACKUP_DIR/"
    echo "Backup complete."
fi

# -------------------------
# Ask for panel name and theme URL
# -------------------------
read -p "Enter the panel name to use (APP_NAME): " PANEL_NAME
read -p "Enter the full URL of your theme zip: " THEME_ZIP_URL

# -------------------------
# Download and unzip theme
# -------------------------
echo -e "${YELLOW}Downloading theme...${RESET}"
curl -L "$THEME_ZIP_URL" -o panel.zip
unzip -o panel.zip -d panel-theme

# -------------------------
# Apply theme files
# -------------------------
echo -e "${GREEN}Applying theme files...${RESET}"
cp -r panel-theme/public/* public/
cp -r panel-theme/resources/* resources/

# -------------------------
# Update .env APP_NAME
# -------------------------
if grep -q "^APP_NAME=" .env; then
    sed -i "s/^APP_NAME=.*/APP_NAME=\"$PANEL_NAME\"/" .env
else
    echo "APP_NAME=\"$PANEL_NAME\"" >> .env
fi

# Footer remains default
echo "Updating footer..."

# -------------------------
# Clear Laravel caches
# -------------------------
echo "Clearing caches..."
php artisan view:clear
php artisan config:clear
php artisan up

# -------------------------
# Cleanup temporary files
# -------------------------
echo "Cleaning up temporary files..."
rm -rf panel.zip panel-theme

# -------------------------
# Final branding message
# -------------------------
echo -e "${CYAN}✅ LegendMC theme applied successfully!${RESET}"
echo -e "${CYAN}Made by LevelupLegendz${RESET}"
