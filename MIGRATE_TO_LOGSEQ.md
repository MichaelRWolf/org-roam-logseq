# Migration to Logseq: Complete Setup and Best Practices

## Overview

This document outlines the migration from a complex org-mode/org-roam/obsidian setup to a simplified Logseq-based system that works seamlessly with Emacs and mobile devices. **This plan is focused solely on the org-roam-logseq project and does not consider any other independent projects or submodules.**

**Note: org-roam is being abandoned due to reliability issues. This migration focuses on using the existing org-roam data directly with Logseq, without any org-roam dependencies.**

## Current State Analysis

### Problem Areas
- **Multiple conflicting directories**: org-roam data, obsidian-vault, iCloud sync locations
- **Complex symlink chains**: `~/org-roam-logseq-nodes-MichaelRWolf` → iCloud location
- **Obsidian references**: Migration scripts and configurations no longer needed
- **Permission issues**: iCloud directories with restricted access
- **Git version control**: Multiple repos and submodules creating confusion
- **org-roam reliability**: Abandoning org-roam due to persistent issues

### Current Directory Structure
```
org-roam-logseq/
├── logseq/                           # Unused config
├── migrate-org-to-obsidian/
│   ├── bin/org_roam_to_obsidian.sh   # Obsidian migration script
│   └── ...
└── ...
```

## Migration Plan

### Phase 1: Remove Obsidian References

#### 1.1 Remove Obsidian Migration Scripts
```bash
# Remove Obsidian migration scripts
rm -rf migrate-org-to-obsidian/bin/org_roam_to_obsidian.sh*
rm -rf migrate-org-to-obsidian/elisp/org_roam_to_obsidian.el
```

#### 1.2 Remove Obsidian Vault Directory
```bash
# Remove the entire Obsidian vault directory (if it exists)
# Note: This path may not exist if the portable-profile submodule was already removed
if [ -d "migrate-org-to-obsidian/portable-profile/michael/obsidian-vault/" ]; then
  rm -rf migrate-org-to-obsidian/portable-profile/michael/obsidian-vault/
fi
```

#### 1.3 Clean Up Empty Directories
```bash
# Remove unused logseq config in workspace root
rm -rf logseq/
```

### Phase 2: Use Existing Data In Place

#### 2.1 Identify Current Working Directory
```bash
# Determine where your current working Logseq data is located
# This should be the directory that contains your actual notes and journals
ls -la ~/org-roam-logseq-nodes-MichaelRWolf
```

#### 2.2 Use Existing Data Directory for Logseq
The existing org-roam data directory will be used directly by Logseq:
```bash
# The existing directory contains all your notes and can be used by Logseq
# No need to copy or move anything - use it in place
ls -la ~/org-roam-logseq-nodes-MichaelRWolf/pages/
ls -la ~/org-roam-logseq-nodes-MichaelRWolf/journals/
```

#### 2.3 Verify Logseq Configuration
Ensure Logseq is configured to use the existing data directory:
```bash
# Check if Logseq config exists in your working directory
ls -la ~/org-roam-logseq-nodes-MichaelRWolf/logseq/

# Configure Logseq to use this directory as its workspace
# In Logseq app: Settings → Advanced → Workspace → Add workspace
# Point to: ~/org-roam-logseq-nodes-MichaelRWolf
```

#### 2.4 Remove Obsidian Migration Directory (Optional)
```bash
# Option A: Remove the entire migration directory if no longer needed
rm -rf migrate-org-to-obsidian/

# Option B: Keep the directory but remove only Obsidian-specific files
rm -rf migrate-org-to-obsidian/bin/org_roam_to_obsidian.sh*
rm -rf migrate-org-to-obsidian/elisp/org_roam_to_obsidian.el
```

### Phase 3: Verify Cloud Sync Setup

#### 3.1 Check Current iCloud Sync Status
```bash
# Verify that your existing directory is properly synced with iCloud
ls -la ~/org-roam-logseq-nodes-MichaelRWolf
# This should show a symlink to the iCloud location if sync is working
```

#### 3.2 Ensure Mobile App Access
- Open Logseq mobile app
- Verify it can access your notes
- Test creating a new note to ensure sync works in both directions

### Phase 4: Git Version Control

#### 4.1 Initialize Git Repository in Existing Directory
```bash
cd ~/org-roam-logseq-nodes-MichaelRWolf
git init
echo "*.log" >> .gitignore
echo ".DS_Store" >> .gitignore
echo "logseq/bak/" >> .gitignore
echo "logseq/.recycle/" >> .gitignore
git add .
git commit -m "Initial Logseq workspace setup using existing org-roam data"
```

#### 4.2 Backup Strategy
```bash
# Create backup script
cat > ~/org-roam-logseq-nodes-MichaelRWolf/backup.sh << 'EOF'
#!/bin/bash
cd ~/org-roam-logseq-nodes-MichaelRWolf
git add .
git commit -m "Auto-backup $(date)"
git push origin main
EOF
chmod +x ~/org-roam-logseq-nodes-MichaelRWolf/backup.sh
```

## Recommended Practices

### Emacs Configuration Best Practices

#### Complete Org-Mode Configuration
```elisp
;; Complete org-mode configuration for Logseq integration
(use-package org
  :ensure t
  :custom
  ;; Directory and file settings
  (org-directory "~/org-roam-logseq-nodes-MichaelRWolf")
  (org-agenda-files (list "~/org-roam-logseq-nodes-MichaelRWolf/pages"
                          "~/org-roam-logseq-nodes-MichaelRWolf/journals"))
  ;; Babel settings
  (org-babel-load-languages '((emacs-lisp . t) (shell . t) (python . t)))
  (org-babel-python-command "python3")
  :config
  ;; Initialize babel languages
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
  :bind
  ;; Keybindings
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   (:map org-mode-map
         ("M-S-<right>" . org-table-insert-column)
         ("M-S-<left>" . org-table-delete-column))))
```



### File Organization Best Practices

#### 1. Directory Structure
```
~/org-roam-logseq-nodes-MichaelRWolf/
├── pages/           # Main notes and pages (existing org-roam data)
│   ├── People/      # Person notes
│   ├── Projects/    # Project notes
│   ├── Organizations/ # Organization notes
│   └── ...
├── journals/        # Daily journal entries (existing org-roam data)
├── logseq/          # Logseq configuration
│   ├── config.edn   # Main config
│   └── custom.css   # Custom styling
├── assets/          # Images and attachments
└── templates/       # Note templates
```

#### 2. File Naming Conventions
- **Pages**: `YYYYMMDDHHMMSS-descriptive-name.org`
- **Journals**: `YYYY-MM-DD.org`
- **Templates**: `template-name.org`

#### 3. Content Organization
```org
#+title: Page Title
#+filetags: :tag1:tag2:

* Main Content
** Subsection
*** Details

* References
- [[Related Page]]
- [External Link](https://example.com)

* Notes
%T Created
%T Updated
```

### Logseq Configuration Best Practices

#### 1. Essential Settings
```clojure
{:preferred-format :org
 :journal/page-title-format "yyyy-MM-dd (EEE)"
 :journal/file-name-format "yyyy-MM-dd"
 :file/name-format :triple-lowbar
 :org-mode/insert-file-link? true
 :preferred-workflow :todo
 :start-of-week 6}
```

#### 2. Mobile Sync Settings
```clojure
{:graph/settings {:builtin-pages? true, :journal? true}
 :mobile/photo {:allow-editing? true, :quality 80}
 :feature/enable-journals? true}
```

## Migration Checklist

### Pre-Migration
- [ ] Backup all current data
- [ ] Document current Emacs configuration
- [ ] Identify all symlinks and their purposes

### Migration Steps
- [ ] Remove Obsidian references
- [ ] Configure Logseq to use existing org-roam data directory
- [ ] Update Emacs configuration (remove org-roam dependencies)
- [ ] Verify cloud sync setup
- [ ] Initialize git repository in existing directory
- [ ] Test Logseq integration
- [ ] Test mobile sync

### Post-Migration
- [ ] Verify all notes are accessible in Logseq
- [ ] Test basic org-mode functionality in Emacs
- [ ] Test mobile app sync
- [ ] Update any scripts or automation
- [ ] Document new setup

## Troubleshooting

### Common Issues

#### 1. Permission Denied on iCloud
- Use Finder to access iCloud Logseq folder
- Grant full disk access to terminal/emacs
- Consider using local directory with manual sync

#### 2. Logseq Database Issues
```bash
# Reset Logseq database if needed
# In Logseq app: Settings → Advanced → Clear cache and restart
```

#### 3. Logseq Sync Issues
- Check iCloud storage space
- Verify Logseq app permissions
- Restart Logseq app and sync

### Performance Optimization

#### 1. Large File Handling
```bash
# Logseq handles large files automatically
# If performance issues occur, consider splitting large files
```

#### 2. Logseq Performance Optimization
```bash
# Clear Logseq cache periodically
# In Logseq app: Settings → Advanced → Clear cache
```

## Conclusion

This migration plan provides a clean, simplified setup that:
- Removes all Obsidian complexity
- Abandons org-roam due to reliability issues
- Uses existing org-roam data directly with Logseq (no copying or moving)
- Establishes a single source of truth for notes
- Enables seamless Logseq and mobile integration
- Provides proper version control and backup
- Follows best practices for maintainability

The key is to use your existing data in place without creating duplicates or dependencies on broken tools.
