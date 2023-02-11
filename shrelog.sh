#!/bin/bash

if ! command -v shred > /dev/null; then
  echo "Error: shred not found. Please install it and try again."
  exit 1
fi

files_to_delete=(
  ~/.bash_history
  ~/.zsh_history
  ~/.viminfo
  ~/.mysql_history
  ~/.python_history
  ~/.psql_history
  ~/.nano_history
  ~/.node_repl_history
  ~/.wget-hsts
)

dirs_to_delete=(
  ~/.cache/chromium
  ~/.cache/google-chrome
  ~/.mozilla/firefox
)

sensitive_logs=(
  "/var/log/auth.log"
  "/var/log/secure"
  "/var/log/syslog"
  "/var/log/nginx/access.log"
  "/var/log/nginx/error.log"
  "/var/log/httpd/access_log"
  "/var/log/httpd/error_log"
)

read_sensitive_strings() {
  local sensitive_log=$1
  local strings_to_look_for=("HTTP" "200" "key")

  if [ -f "$sensitive_log" ]; then
    echo "Reading sensitive strings from log file: $sensitive_log"
    for string in "${strings_to_look_for[@]}"; do
      grep -i "$string" "$sensitive_log"
    done
  else
    echo "Error: log file not found: $sensitive_log"
  fi
}
echo 'Script created by @r3x08.'
echo "Select an option:"
echo "1. Delete log files"
echo "2. Read sensitive strings in security-based logs"
echo "3. About"
echo "4. Exit"
read -p "Enter your choice (1-4): " choice

case "$choice" in
  1)
    # Delete files
    for file in "${files_to_delete[@]}"; do
      if [ -f "$file" ]; then
        shred -v -n 3 "$file"
        echo "Deleted file: $file"
      fi
    done

    # Delete directories
    for dir in "${dirs_to_delete[@]}"; do
      if [ -d "$dir" ]; then
        find "$dir" -type f -exec shred -n 3 -f -z {} +
        echo "Deleted directory: $dir"
      fi
    done
    ;;
  2)
    for sensitive_log in "${sensitive_logs[@]}"; do
      read_sensitive_strings "$sensitive_log"
    done
    ;;
  3)
    open "https://github.com/r3x08"
    ;;
  4)
    exit 0
    ;;
  *)
    echo "Invalid choice. Please try again."
    ;;
esac

sleep 3 && clear && echo "Done."

