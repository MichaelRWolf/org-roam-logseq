#!/bin/bash
set -euo pipefail

# Migrate org-roam files to Obsidian-compatible Markdown
# - Converts .org to .md
# - Preserves frontmatter and links
# - Basic table and heading conversion assumed

SRC_DIR="$HOME/org-roam"
DST_DIR="$HOME/obsidian-vault"

mkdir -p "$DST_DIR"

find "$SRC_DIR" -type f -name '*.org' | while read -r orgfile; do
  relpath="${orgfile#$SRC_DIR/}"
  mdfile="$DST_DIR/${relpath%.org}.md"
  mkdir -p "$(dirname "$mdfile")"

  emacs --batch "$orgfile" \
    --load org-export-init.el \
    --eval "(org-export-to-file 'gfm \"$mdfile\" nil nil nil t)"
done
