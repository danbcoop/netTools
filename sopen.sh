#!/bin/bash

# Script to copy a file from remote computer via scp and open it with xdg-open

# Configuration - MODIFY THESE VALUES
REMOTE_USER="daniel"          # Remote username
REMOTE_HOST="nb1"          # Remote IP or hostname
REMOTE_PATH="/path/to/remote/file"   # Full path to file on remote machine
LOCAL_TEMP_DIR="/tmp"                # Local temporary directory

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_error() {
    echo -e "${RED}Error: $1${NC}"
}

print_success() {
    echo -e "${GREEN}Success: $1${NC}"
}

print_info() {
    echo -e "${YELLOW}Info: $1${NC}"
}

# Check if filename is provided as argument
if [ $# -ge 1 ]; then
    # If first argument is provided, use it as remote path
    REMOTE_PATH="$1"
    
    # If second argument is provided, use it as remote user
    if [ $# -ge 2 ]; then
        REMOTE_USER="$2"
    fi
    
    # If third argument is provided, use it as remote host
    if [ $# -ge 3 ]; then
        REMOTE_HOST="$3"
    fi
fi

# Extract filename from path
FILENAME=$(basename "$REMOTE_PATH")
LOCAL_FILE="${LOCAL_TEMP_DIR}/${FILENAME}"

# Flag to track if we need to copy the file
NEED_COPY=1

# Check if file already exists in /tmp
if [ -f "$LOCAL_FILE" ]; then
    print_info "File already exists at ${LOCAL_FILE}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Using existing file"
        NEED_COPY=0  # Don't copy, use existing file
    else
        print_info "Will overwrite existing file"
        # Remove existing file
        rm -f "$LOCAL_FILE"
        NEED_COPY=1  # Copy the file
    fi
fi

# Display what we're about to do
echo "========================================="
if [ $NEED_COPY -eq 1 ]; then
    echo "Copying file from remote machine:"
    echo "  Source: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
    echo "  Destination: ${LOCAL_FILE}"
else
    echo "Using existing local file:"
    echo "  File: ${LOCAL_FILE}"
fi
echo "========================================="

# Perform the SCP copy only if needed
if [ $NEED_COPY -eq 1 ]; then
    print_info "Starting SCP transfer..."

    if scp "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" "$LOCAL_FILE"; then
        print_success "File copied successfully to ${LOCAL_FILE}"
    else
        print_error "SCP transfer failed!"
        print_info "Please check:"
        echo "  - Remote host is reachable (ping ${REMOTE_HOST})"
        echo "  - SSH connection works (ssh ${REMOTE_USER}@${REMOTE_HOST})"
        echo "  - Remote file exists (ls ${REMOTE_PATH})"
        echo "  - You have proper permissions"
        exit 1
    fi
else
    print_info "Skipping SCP transfer (using existing file)"
fi

# Verify file exists and has content
if [ -f "$LOCAL_FILE" ] && [ -s "$LOCAL_FILE" ]; then
    print_info "Opening file with xdg-open..."
    
    # Open the file with xdg-open
    if xdg-open "$LOCAL_FILE" 2>/dev/null; then
        print_success "File opened successfully with default application"
    else
        print_error "Failed to open file with xdg-open"
        print_info "You can manually open it with: xdg-open ${LOCAL_FILE}"
    fi
else
    print_error "File does not exist or is empty: ${LOCAL_FILE}"
    exit 1
fi

# Optionally, ask if user wants to keep the file
echo
read -p "Keep the file in /tmp? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "File kept at ${LOCAL_FILE}"
    print_info "Note: /tmp files may be deleted on system reboot"
else
    rm -f "$LOCAL_FILE"
    print_info "File removed from /tmp"
fi

exit 0
