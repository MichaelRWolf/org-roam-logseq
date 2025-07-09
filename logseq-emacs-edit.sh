#!/bin/bash
# logseq-emacs-edit.sh
# Script for Logseq to edit files using emacsclient
#
# Usage: ./logseq-emacs-edit.sh <file-path>
# Environment variables:
#   EDITOR=emacsclient (default)
#   VISUAL=emacsclient (fallback)

set -e



# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Function to check if emacs daemon is running
check_emacs_daemon() {
    if ! emacsclient --eval "(+ 1 1)" >/dev/null 2>&1; then
        log "Emacs daemon not running. Starting emacs daemon..."
        emacs --daemon
        sleep 2
    fi
}

# Function to edit file with emacsclient
edit_file() {
    local file_path="$1"
    
    if [[ -z "$file_path" ]]; then
        log "Error: No file path provided"
        echo "Usage: $0 <file-path>"
        exit 1
    fi
    
    if [[ ! -f "$file_path" ]]; then
        log "Error: File does not exist: $file_path"
        exit 1
    fi
    
    # Convert to absolute path if needed
    if [[ ! "$file_path" = /* ]]; then
        file_path="$(pwd)/$file_path"
    fi
    
    log "Editing file: $file_path"
    
    # Try EDITOR first, then VISUAL, then default to emacsclient
    local editor_cmd=""
    if command -v "$EDITOR" >/dev/null 2>&1; then
        editor_cmd="$EDITOR"
    elif command -v "$VISUAL" >/dev/null 2>&1; then
        editor_cmd="$VISUAL"
    else
        editor_cmd="emacsclient"
    fi
    
    log "Using editor: $editor_cmd"
    
    # Check if emacs daemon is running
    check_emacs_daemon
    
    # Edit the file
    if [[ "$editor_cmd" == *"emacsclient"* ]]; then
        # Use emacsclient with specific options for better integration
        "$editor_cmd" --no-wait --create-frame "$file_path"
    else
        # Use other editor
        "$editor_cmd" "$file_path"
    fi
    
    log "File opened in editor"
}

# Main execution
main() {
    log "Logseq Emacs Edit Script started"
    
    # Check if we have a file argument
    if [[ $# -eq 0 ]]; then
        log "Error: No arguments provided"
        echo "Usage: $0 <file-path>"
        exit 1
    fi
    
    edit_file "$1"
    
    log "Script completed successfully"
}

# Run main function with all arguments
main "$@" 