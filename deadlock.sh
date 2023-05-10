#!/bin/bash

# Detect the desktop environment
desktop_environment=""
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  desktop_environment="gnome"
elif [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
  desktop_environment="kde"
fi

# Get a list of all processes and their open files
processes=$(lsof)

# Check each process for any blocked or stuck state
while read -r line; do
  pid=$(echo "$line" | awk '{print $2}')
  name=$(ps -p "$pid" -o comm=)
  state=$(echo "$line" | awk '{print $8}')

  # If a process is stuck, print the PID, name, and state
  if [[ "$state" == "BLOCKED" || "$state" == "STUCK" ]]; then
    echo "Deadlock detected: process $pid ($name) is $state" >> /var/log/deadlock.log

    # Display a desktop notification using the appropriate command
    if [[ "$desktop_environment" == "gnome" ]]; then
      notify-send "Deadlock detected" "Process $pid ($name) is $state"
    elif [[ "$desktop_environment" == "kde" ]]; then
      kdialog --title "Deadlock detected" --passivepopup "Process $pid ($name) is $state" 5
    else
      xdg-open "https://www.example.com/deadlock-detected?pid=$pid&name=$name&state=$state"
    fi
  fi
done <<< "$processes"


