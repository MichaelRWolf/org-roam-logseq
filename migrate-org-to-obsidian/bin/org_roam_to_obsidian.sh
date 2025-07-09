#!/bin/bash
set -euo pipefail

# Migrate org files to Obsidian-compatible Markdown
# Usage:
#   --export-all SRCDIR DESTDIR    : Export all org files from SRCDIR to DESTDIR
#   ORGFILE... DESTDIR             : Export specific org files to DESTDIR

# Get the directory where this script is located
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
ELISP_DIR="$SCRIPT_DIR/../elisp"
ORG_ROAM_SCRIPT="$ELISP_DIR/org_roam_to_obsidian.el"
INIT_SCRIPT="$ELISP_DIR/org-export-init.el"
EARLY_INIT_SCRIPT="$ELISP_DIR/early-init.el"

if [ ! -f "$ORG_ROAM_SCRIPT" ]; then
    echo "Error: $ORG_ROAM_SCRIPT not found"
    exit 1
fi

if [ ! -f "$INIT_SCRIPT" ]; then
    echo "Error: $INIT_SCRIPT not found"
    exit 1
fi

if [ ! -f "$EARLY_INIT_SCRIPT" ]; then
    echo "Error: $EARLY_INIT_SCRIPT not found"
    exit 1
fi

# Ensure clean environment
unset EMACSLOADPATH
unset EMACSDATA
unset EMACSDOC
unset EMACSLOADPATH
unset EMACSPATH
unset EMACSDATA
unset EMACSDOC
unset EMACSPATH
unset EMACSDATA
unset EMACSDOC
unset EMACSPATH

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [--export-all SRCDIR DESTDIR] ORGFILE... DESTDIR"
    exit 1
fi

if [ "$1" = "--export-all" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Error: --export-all requires exactly two arguments: SRCDIR DESTDIR"
        exit 1
    fi
    SRC_DIR="$(realpath "$2")"
    DST_DIR="$(realpath "$3")"
    echo "Starting batch export from $SRC_DIR to $DST_DIR..."
    /usr/local/bin/emacs --no-site-file --no-init-file -L "$ELISP_DIR" --batch \
        --load "$EARLY_INIT_SCRIPT" \
        --load "$INIT_SCRIPT" \
        --load "$ORG_ROAM_SCRIPT" \
        --eval "(org-export-all-to-obsidian \"$SRC_DIR\" \"$DST_DIR\")"
else
    # Last argument is destination directory
    DST_DIR="$(realpath "${@: -1}")"
    # All other arguments are org files
    ORG_FILES=("${@:1:$#-1}")
    
    if [ ${#ORG_FILES[@]} -eq 0 ]; then
        echo "Error: No org files specified"
        exit 1
    fi
    
    echo "Exporting ${#ORG_FILES[@]} files to $DST_DIR..."
    mkdir -p "$DST_DIR"
    
    for orgfile in "${ORG_FILES[@]}"; do
        if [ ! -f "$orgfile" ]; then
            echo "Error: File not found: $orgfile"
            exit 1
        fi
        abs_orgfile="$(realpath "$orgfile")"
        echo "Processing: $orgfile"
        /usr/local/bin/emacs --no-site-file --no-init-file -L "$ELISP_DIR" --batch "$abs_orgfile" \
            --load "$EARLY_INIT_SCRIPT" \
            --load "$INIT_SCRIPT" \
            --load "$ORG_ROAM_SCRIPT" \
            --eval "(org-export-obsidian-file \"$abs_orgfile\" \"$DST_DIR\")"
    done
fi

echo "Migration complete!"
