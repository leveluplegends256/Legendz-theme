#!/usr/bin/env bash
# legendz_branding_full.sh
# Animated ASCII branding + menu + theme installer + progress bar

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
# Animate ASCII text with gradient
# -------------------------
animate_logo() {
  clear
  for line in "${ascii_logo[@]}"; do
    local len=${#line}
    for (( i=0; i<len; i++ )); do
      color_index=$(( i * ${#colors[@]} / len ))
      printf "${BOLD}${colors[color_index]}%s${RESET}" "${line:i:1}"
      sleep 0.003
    done
    echo
  done
  echo
}

# -------------------------
# Progress bar function
# -------------------------
progress_bar() {
  local step="$1"
  local total="$2"
  local message="$3"
  local width=40
  local percent=$(( step * 100 / total ))
  local filled=$(( width * step / total ))
  local empty=$(( width - filled ))
  
  printf "\r%s [%-${width}s] %d%%" "$message" "$(printf '#%.0s' $(seq 1 $filled))$(printf ' %.0s' $(seq 1 $empty))" "$percent"
  if [[ $step -eq $total ]]; then
    echo -e " ✅"
  fi
}

# -------------------------
# Show Menu
# -------------------------
show_menu() {
  animate_logo
  echo -e "${BOLD}Select an option:${RESET}"
  echo -e "1) Install theme"
  echo -e "0) Exit"
}

# -------------------------
# Install Theme Function
# -------------------------
install_theme() {
  PANEL_DIR="/var/www/pterodactyl"
  total_steps=9
  step=0

  animate_logo
  echo "Starting theme installation..."

  # Step 1: Enter Maintenance Mode
  ((step++))
  progress_bar "$step" "$total_steps" "Entering maintenance mode..."
  cd "$PANEL_DIR" || { echo "Panel directory not found!"; return 1; }
  php artisan down
  sleep 0.5

  # Step 2: Download the theme
  ((step++))
  progress_bar "$step" "$total_steps" "Downloading NookTheme panel..."
  curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv >/dev/null 2>&1
  sleep 0.5

  # Step 3: Set permissions
  ((step++))
  progress_bar "$step" "$total_steps" "Setting permissions..."
  chmod -R 755 storage/* bootstrap/cache
  sleep 0.5

  # Step 4: Update composer dependencies
  ((step++))
  progress_bar "$step" "$total_steps" "Updating dependencies..."
  composer install --no-dev --optimize-autoloader >/dev/null 2>&1
  sleep 0.5

  # Step 5: Clear compiled template cache
  ((step++))
  progress_bar "$step" "$total_steps" "Clearing template cache..."
  php artisan view:clear >/dev/null 2>&1
  php artisan config:clear >/dev/null 2>&1
  sleep 0.5

  # Step 6: Database updates
  ((step++))
  progress_bar "$step" "$total_steps" "Updating database..."
  php artisan migrate --seed --force >/dev/null 2>&1
  sleep 0.5

  # Step 7: Set ownership
  ((step++))
  progress_bar "$step" "$total_steps" "Setting file ownership..."
  chown -R www-data:www-data "$PANEL_DIR"/*
  sleep 0.5

  # Step 8: Restart queue workers
  ((step++))
  progress_bar "$step" "$total_steps" "Restarting queue workers..."
  php artisan queue:restart >/dev/null 2>&1
  sleep 0.5

  # Step 9: Exit maintenance mode
  ((step++))
  progress_bar "$step" "$total_steps" "Exiting maintenance mode..."
  php artisan up
  sleep 0.5

  echo -e "${BOLD}${colors[2]}Theme installation completed successfully!${RESET}"
  sleep 1
}

# -------------------------
# Main loop
# -------------------------
while true; do
  show_menu
  read -rp "Enter choice: " choice
  case "$choice" in
    1)
      install_theme
      read -rp "Press Enter to return to menu..."
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
