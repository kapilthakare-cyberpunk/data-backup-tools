#!/bin/bash

# This script is called by a udev rule to run the backup script
# within the context of the logged-in user's graphical session.

# Find the user and their active display
USER_NAME="kapilt"
USER_HOME="/home/${USER_NAME}"
export DISPLAY=:0
export XAUTHORITY=${USER_HOME}/.Xauthority

# Path to the main backup script
BACKUP_SCRIPT_PATH="${USER_HOME}/Projects/data-backup-experiments/memory_card_backup.sh"

# Check if the backup script is running, if not, then run it
if ! pgrep -f "${BACKUP_SCRIPT_PATH}" > /dev/null; then
    # Launch the backup script in a new terminal window for interaction
    # We need to use sudo to run the command as the specified user
    sudo -u ${USER_NAME} gnome-terminal -- bash -c "\"${BACKUP_SCRIPT_PATH}\"; exec bash"
fi
