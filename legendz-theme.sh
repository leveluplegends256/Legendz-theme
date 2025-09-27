#!/bin/bash
# LegendMC Pterodactyl Theme Installer (No npm, Prebuilt)
PTERO_DIR="/var/www/pterodactyl"
cd "$PTERO_DIR" || { echo "Panel directory not found! Exiting."; exit 1; }
CYAN="\e[36m"
RESET="\e[0m"
# Animate LevelupLegendz logo
animate_logo() {
  clear
  local logo=(
"ˆˆW     ˆˆˆˆˆˆˆWˆˆW   ˆˆWˆˆˆˆˆˆˆWˆˆW     ˆˆW   ˆˆWˆˆˆˆˆˆW ˆˆW     ˆˆˆˆˆˆˆW ˆˆˆˆˆˆW ˆˆˆˆˆˆˆWˆˆˆW   ˆˆWˆˆˆˆˆˆW ˆˆˆˆˆˆˆW"
"ˆˆQ     ˆˆTPPPP]ˆˆQ   ˆˆQˆˆTPPPP]ˆˆQ     ˆˆQ   ˆˆQˆˆTPPˆˆWˆˆQ     ˆˆTPPPP]ˆˆTPPPP] ˆˆTPPPP]ˆˆˆˆW  ˆˆQˆˆTPPˆˆWZPPˆˆˆT]"
"ˆˆQ     ˆˆˆˆˆW  ˆˆQ   ˆˆQˆˆˆˆˆW  ˆˆQ     ˆˆQ   ˆˆQˆˆˆˆˆˆT]ˆˆQ     ˆˆˆˆˆW  ˆˆQ  ˆˆˆWˆˆˆˆˆW  ˆˆTˆˆW ˆˆQˆˆQ  ˆˆQ  ˆˆˆT] "
"ˆˆQ     ˆˆTPP]  ZˆˆW ˆˆT]ˆˆTPP]  ˆˆQ     ˆˆQ   ˆˆQˆˆTPPP] ˆˆQ     ˆˆTPP]  ˆˆQ   ˆˆQˆˆTPP]  ˆˆQZˆˆWˆˆQˆˆQ  ˆˆQ ˆˆˆT]  "
"ˆˆˆˆˆˆˆWˆˆˆˆˆˆˆW ZˆˆˆˆT] ˆˆˆˆˆˆˆWˆˆˆˆˆˆˆWZˆˆˆˆˆˆT]ˆˆQ     ˆˆˆˆˆˆˆWˆˆˆˆˆˆˆWZˆˆˆˆˆˆT]ˆˆˆˆˆˆˆWˆˆQ ZˆˆˆˆQˆˆˆˆˆˆT]ˆˆˆˆˆˆˆW"
"ZPPPPPP]ZPPPPPP]  ZPPP]  ZPPPPPP]ZPPPPPP] ZPPPPP] ZP]     ZPPPPPP]ZPPPPPP]  ZPPPPP]  ZPPPPPP]ZP]  ZPPP]ZPPPPP] ZPPPPPP]"
  )
  for line in "${logo[@]}"; do
    echo -e "${CYAN}${line}${RESET}"
    sleep 0.2
  done
  echo ""
  sleep 0.5
}
animate_logo
# Ask user for backup
read -p "Do you want to backup current panel? (y/N): " backup_choice
if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
    BACKUP_DIR="$PTERO_DIR/backup_$(date +%s)"
    echo "Creating backup at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    cp -r public "$BACKUP_DIR/"
    cp -r resources "$BACKUP_DIR/"
    echo "Backup complete."
fi
# Ask for panel name
read -p "Enter the panel name to use (APP_NAME): " PANEL_NAME
# Ask for theme zip URL
read -p "Enter the full URL of your theme zip: " THEME_ZIP_URL
# Download and unzip theme
echo "Downloading theme..."
curl -L "$THEME_ZIP_URL" -o panel.zip
unzip -o panel.zip -d panel-theme
# Copy theme files
echo "Applying theme files..."
cp -r panel-theme/public/* public/
cp -r panel-theme/resources/* resources/
# Update APP_NAME in .env
if grep -q "^APP_NAME=" .env; then
    sed -i "s/^APP_NAME=.*/APP_NAME=\"$PANEL_NAME\"/" .env
else
    echo "APP_NAME=\"$PANEL_NAME\"" >> .env
fi
# Footer remains unchanged (do not overwrite)
echo "Updating footer..."
# Clear Laravel caches
echo "Clearing caches..."
php artisan view:clear
php artisan config:clear
php artisan up
# Cleanup temporary files
echo "Cleaning up temporary files..."
rm -rf panel.zip panel-theme
echo " LegendMC theme applied successfully!"
