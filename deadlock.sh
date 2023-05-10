#!/bin/bash

# Detect the desktop environment
desktop_environment=""
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  desktop_environment="gnome"
elif [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
  desktop_environment="kde"
fi

# Get a list of all processes and their states
processes=$(ps -eo pid,state,command)

# Check each process for any blocked or stuck state
while read -r line; do
  # Extract the process ID, state, and command from the output
  pid=$(echo "$line" | awk '{print $1}')
  state=$(echo "$line" | awk '{print $2}')
  command=$(echo "$line" | awk '{$1=""; $2=""; print $0}')

  # If a process is stuck, print the PID, command, and state
  if [[ "$state" == "D" || "$state" == "R+" ]]; then
    echo "Deadlock detected: process $pid ($command) is $state" >> /var/log/deadlock.log

    # Display a desktop notification using the appropriate command
    if [[ "$desktop_environment" == "gnome" ]]; then
      notify-send "Deadlock detected" "Process $pid ($command) is $state"
    elif [[ "$desktop_environment" == "kde" ]]; then
      kdialog --title "Deadlock detected" --passivepopup "Process $pid ($command) is $state" 5
    else
      xdg-open "https://www.example.com/deadlock-detected?pid=$pid&command=$command&state=$state"
    fi
  fi
done <<< "$processes"








