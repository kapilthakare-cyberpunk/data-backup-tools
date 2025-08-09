#!/bin/bash

# --- Configuration ---
LOCAL_BACKUP_DIR="/home/kapilt/Pictures"
GDRIVE_REMOTE="gdrive-general"
SOURCE_DIR="/media/kapilt/EOS_DIGITAL" # Source directory for camera files

# --- Colors and Emojis ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

EMOJI_CAMERA="📸"
EMOJI_FOLDER="📁"
EMOJI_CLOUD="☁️"
EMOJI_ROCKET="🚀"
EMOJI_CHECK="✅"
EMOJI_CROSS="❌"
EMOJI_WARN="⚠️"

# --- Functions ---

# Function to get project name
get_project_name() {
    while true; do
        read -p "$(echo -e ${BLUE}"${EMOJI_FOLDER} Enter project name: "${NC})" PROJECT_NAME
        if [ -n "$PROJECT_NAME" ]; then
            break
        else
            echo -e "${YELLOW}${EMOJI_WARN} Project name cannot be empty. Please try again.${NC}"
        fi
    done
}

# Function to create local backup
create_local_backup() {
    echo -e "\n${GREEN}${EMOJI_CAMERA} Starting local backup...${NC}"
    BACKUP_NAME="${PROJECT_NAME}_${DATE}"
    DEST_PATH="${LOCAL_BACKUP_DIR}/${BACKUP_NAME}"
    
    mkdir -p "${DEST_PATH}"
    
    echo -e "${BLUE}Copying files from ${SOURCE_DIR} to ${DEST_PATH}${NC}"
    if rsync -ah --progress "${SOURCE_DIR}/" "${DEST_PATH}/"; then
        echo -e "${GREEN}${EMOJI_CHECK} Local backup created successfully: ${DEST_PATH}${NC}"
    else
        echo -e "${RED}${EMOJI_CROSS} Error creating local backup.${NC}"
        exit 1
    fi
}

# Function to create GDrive backup
create_gdrive_backup() {
    echo -e "\n${GREEN}${EMOJI_CLOUD} Starting GDrive backup...${NC}"
    GDRIVE_PATH="gdrive-general/${BACKUP_NAME}"

    echo -e "${BLUE}Copying files to ${GDRIVE_PATH}${NC}"
    if rclone copy --progress "${DEST_PATH}" "${GDRIVE_PATH}"; then
        echo -e "${GREEN}${EMOJI_CHECK} GDrive backup created successfully: ${GDRIVE_PATH}${NC}"
    else
        echo -e "${RED}${EMOJI_CROSS} Error creating GDrive backup.${NC}"
    fi
}

# --- Main Function ---
main() {
    DATE=$(date +%Y%m%d_%H%M%S)
    
    get_project_name

    create_local_backup
    
    read -p "$(echo -e ${YELLOW}"Do you want to create a GDrive backup? (y/n): "${NC})" gdrive_choice
    case "$gdrive_choice" in
        y|Y ) create_gdrive_backup;;
        * ) echo -e "${BLUE}Skipping GDrive backup.${NC}";;
    esac
    
    echo -e "\n${GREEN}${EMOJI_ROCKET} All backups complete!${NC}"
    
    # Open the local backup folder
    echo -e "${BLUE}Opening backup folder: ${DEST_PATH}${NC}"
    xdg-open "${DEST_PATH}"

    read -p "$(echo -e ${YELLOW}"\n${EMOJI_WARN} Do you want to format the memory card? (y/n): "${NC})" format_choice
    case "$format_choice" in
        y|Y )
            # It's dangerous to hardcode the device. Let's find it.
            # This is still risky, so we will add a strong warning.
            echo -e "${RED}${EMOJI_WARN} WARNING: This will permanently delete all data on the selected device.${NC}"
            # List block devices to help the user
            lsblk -d -o NAME,SIZE,MODEL
            read -p "$(echo -e ${YELLOW}"Enter the device to format (e.g., /dev/sdX): "${NC})" device_to_format
            if [ -b "$device_to_format" ]; then
                sudo mkfs.vfat "$device_to_format"
                echo -e "${GREEN}${EMOJI_CHECK} Memory card formatted.${NC}"
            else
                echo -e "${RED}${EMOJI_CROSS} Invalid device. Formatting cancelled.${NC}"
            fi
            ;;
        n|N )
            echo -e "${BLUE}Skipping memory card format.${NC}"
            ;;
    esac
    
    echo -e "\n${GREEN}Backup process finished!${NC}"
}

# --- Run ---
main