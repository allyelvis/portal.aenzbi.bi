#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
LOG_FILE="../logs/pos.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Load environment variables
log "Loading environment variables..."
if [ -f ../config/.env ]; then
    export $(cat ../config/.env | xargs)
else
    log "Error: .env file not found" >&2
    exit 1
fi

# Load libraries
log "Loading library files..."
if [ -f ../lib/database.sh ]; then
    source ../lib/database.sh
else
    log "Error: database.sh file not found" >&2
    exit 1
fi

# Function to update the system
update_system() {
    log "Updating system packages..."
    if sudo apt update && sudo apt upgrade -y; then
        log "System update completed successfully."
    else
        log "Error: System update failed" >&2
        exit 1
    fi
}

# Function to initialize the database
initialize_database() {
    log "Initializing database..."
    if db_connect && db_setup; then
        log "Database initialized successfully."
    else
        log "Error: Database initialization failed" >&2
        exit 1
    fi
}

# Main script execution
main() {
    update_system
    initialize_database
    log "POS System setup complete."
}

main