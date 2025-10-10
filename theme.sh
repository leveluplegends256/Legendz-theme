#!/usr/bin/env bash
# legendz_branding_install.sh
# Animated ASCII branding with gradient + theme installer

# -------------------------
# Colors for gradient (yellow → red)
# -------------------------
colors=(
  "\e[38;2;255;227;9m"   # yellow
  "\e[38;2;255;219;7m"
  "\e[38;2;255;212;5m"
  "\e[38;2;255;204;2m"
  "\e[38;2;255;147;0m"
  "\e[38;2;255;98;0m"
  "\e[38;2;255;49;0m"    # red
)
BOLD='\e[1m'
RESET='\e[0m'

# -------------------------
# ASCII Logo
# -------------------------
ascii_logo=(
" / \\---------------,"
" \\_,|              |"
"    |    Legendz   |"
"    |  ,-------------"
"    \\_/____________/"
)

# -------------------------
# Animate function
# -------------------------
animate_logo() {
  for line in "${ascii_logo[@]}"; do
    local len=${#line}
    for (( i=0; i<len; i++ )); do
      color_index=$(( i * ${#colors[@]} / len ))
      printf "${BOLD}${colors[color_index]}%s${RESET}" "${line:i:1}"
      sleep 0.005
    done
    echo
  done
}

# -------------------------
# Show Menu
# -------------------------
show_menu() {
  echo
  echo -e "${BOLD}Select an option:${RESET}"
  echo -e "1) Install theme"
  echo -e "0) Exit"
}

# -------------------------
# Install Theme Function
# -------------------------
install_theme() {
  echo -e "${BOLD}${colors[3]}Starting theme installation...${RESET}"
  
  PANEL_DIR="/var/www/pterodactyl"
  
  # Enter Maintenance Mode
  echo "➡ Entering maintenance mode..."
  cd "$PANEL_DIR" || { echo "Panel directory not found!"; return 1; }
  php artisan down

  # Download the theme
  echo "⬇ Downloading latest NookTheme panel..."
  curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv

  # Set permissions
  echo "🔧 Setting permissions on storage and cache..."
  chmod -R 755 storage/* bootstrap/cache

  # Update dependencies
  echo "📦 Updating composer dependencies..."
  composer install --no-dev --optimize-autoloader

  # Clear compiled template cache
  echo "🧹 Clearing template cache..."
  php artisan view:clear
  php artisan config:clear

  # Database updates
  echo "🗄 Updating database schema..."
  php artisan migrate --seed --force

  # Set proper ownership (default www-data)
  echo "🛡 Setting proper file ownership..."
  chown -R www-data:www-data "$PANEL_DIR"/*

  # Restart queue workers
  echo "🔄 Restarting queue workers..."
  php artisan queue:restart

  # Exit Maintenance Mode
  echo "✅ Exiting maintenance mode..."
  php artisan up

  echo -e "${BOLD}${colors[2]}Theme installation completed successfully!${RESET}"
}

# -------------------------
# Main Script
# -------------------------
clear
animate_logo

# Optional flashing effect
for i in {1..2}; do
  clear
  for line in "${ascii_logo[@]}"; do
    echo -e "${BOLD}${colors[0]}$line${RESET}"
  done
  sleep 0.2
  clear
  sleep 0.2
done

# Menu loop
while true; do
  show_menu
  read -rp "Enter choice: " choice
  case "$choice" in
    1)
      install_theme
      break
      ;;
    0)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option. Try again."
      ;;
  esac
done
