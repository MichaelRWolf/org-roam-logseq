# org-roam-logseq
Elisp (Emacs Lisp) files to allow Emacs org-roam to play well with logseq application

## Overview

This repository provides tools for integrating Emacs with Logseq, allowing you to edit Logseq files directly in Emacs using `emacsclient`.

## Components

### 1. Emacs Integration Script (`logseq-emacs-edit.sh`)

A bash script that Logseq can use to open files in Emacs via `emacsclient`.

**Features:**
- Automatically starts emacs daemon if not running
- Respects `EDITOR` and `VISUAL` environment variables
- Provides detailed logging for troubleshooting
- Handles file path validation and conversion

**Installation:**
```bash
# Copy to standard location
sudo cp logseq-emacs-edit.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/logseq-emacs-edit.sh

# Set environment variables (optional)
# You can set these in your shell profile or export them manually:
export EDITOR=emacsclient
export VISUAL=emacsclient
```

**Logseq Configuration:**
1. Open Logseq app
2. Go to Settings → Advanced → External Editor
3. Set **Editor Path**: `/usr/local/bin/logseq-emacs-edit.sh`
4. Set **Arguments**: `{file}` (or `%f` depending on Logseq version)

### 2. Migration Guide (`MIGRATE_TO_LOGSEQ.md`)

Comprehensive guide for migrating from org-roam/obsidian to a simplified Logseq setup.

### 3. Legacy org-roam Integration (`lisp/org-roam-logseq.el`)

**Note: This is deprecated.** The org-roam integration is no longer maintained due to reliability issues. See the migration guide for the current approach.

## Usage

Once configured, you can:
- Right-click on any block in Logseq and select "Open in External Editor"
- The file will open in Emacs using `emacsclient`
- Changes made in Emacs will be reflected in Logseq when you save

## Troubleshooting

### Script Issues
- Check script permissions: `ls -la /usr/local/bin/logseq-emacs-edit.sh`
- Verify emacs daemon is running: `emacsclient --eval "(+ 1 1)"`
- Check script logs for error messages

### Logseq Integration Issues
- Ensure the script path is correct in Logseq settings
- Try different argument formats: `{file}`, `%f`, or `$1`
- Restart Logseq after configuration changes

## Migration

For users migrating from org-roam, see `MIGRATE_TO_LOGSEQ.md` for a complete migration plan that:
- Removes org-roam dependencies
- Uses existing data directly with Logseq
- Maintains iCloud sync for mobile access
- Provides proper version control

# Inspiration

Inspired by https://coredumped.dev/2021/05/26/taking-org-roam-everywhere-with-logseq/ which pointed to https://gist.github.com/zot/ddf1a89a567fea73bc3c8a209d48f527, I created this repo just in case the gist went away.

Taking org-roam everywhere with logseq. (2021, May 26). Coredumped.dev. https://coredumped.dev/2021/05/26/taking-org-roam-everywhere-with-logseq/

262588213843476. (2023, March 13). org-roam-logseq.el. Gist. https://gist.github.com/zot/ddf1a89a567fea73bc3c8a209d48f527

* TODO
- [ ]


‌