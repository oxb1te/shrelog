#!/bin/bash

check_command() {
  command_name=$1
  if ! command -v "$command_name" >/dev/null; then
    echo "Error: $command_name not found. Please install it and try again."
    exit 1
  fi
}

delete_files() {
  files=("$@")
  for file in "${files[@]}"; do
    if [ -f "$file" ]; then
      shred -v -n 3 "$file" || {
        echo "Error: Failed to delete file: $file"
        exit 1
      }
      echo "Deleted file: $file"
    fi
  done
}

delete_directories() {
  dirs=("$@")
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      find "$dir" -type f -exec shred -n 3 -f -z {} + || {
        echo "Error: Failed to delete directory: $dir"
        exit 1
      }
      echo "Deleted directory: $dir"
    fi
  done
}

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
    check_command "shred"
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
    delete_files "${files_to_delete[@]}"
    delete_directories "${dirs_to_delete[@]}"
    ;;
  2)
    sensitive_logs=(
      "/var/log/auth.log"
      "/var/log/secure"
      "/var/log/syslog"
      "/var/log/nginx/access.log"
      "/var/log/nginx/error.log"
      "/var/log/httpd/access_log"
      "/var/log/httpd/error_log"
    )
    for sensitive_log in "${sensitive_logs[@]}"; do
      if [ -f "$sensitive_log" ]; then
        read_sensitive_strings "$sensitive_log"
      else
        echo "Error: log file not found: $sensitive_log"
      fi
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
