# Migration to Logseq: Complete Setup and Best Practices

## Overview

This document outlines the migration from a complex org-mode/org-roam/obsidian setup to a simplified Logseq-based system that works seamlessly with Emacs and mobile devices.

## Current State Analysis

### Problem Areas
- **Multiple conflicting directories**: org-roam, obsidian-vault, iCloud sync locations
- **Complex symlink chains**: `~/org-roam-logseq-nodes-MichaelRWolf` → iCloud location
- **Obsidian references**: Migration scripts and configurations no longer needed
- **Permission issues**: iCloud directories with restricted access
- **Git version control**: Multiple repos and submodules creating confusion

**Note**: The Portable_Profile submodule and its `michael` symlink to home directory are ignored in this migration plan as they are part of a separate system.

### Current Directory Structure
```
org-roam-logseq/
├── logseq/                           # Unused config
├── migrate-org-to-obsidian/
│   ├── portable-profile/
│   │   ├── michael -> /Users/michael  # Problematic symlink
│   │   └── ...
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
# Remove the entire Obsidian vault directory
rm -rf migrate-org-to-obsidian/portable-profile/michael/obsidian-vault/
```

#### 1.3 Clean Up Empty Directories
```bash
# Remove unused logseq config in workspace root
rm -rf logseq/
```

### Phase 2: Simplify Directory Structure

#### 2.1 Create Clean Logseq Workspace
```bash
# Create new local Logseq directory structure
mkdir -p ~/logseq-workspace/{pages,journals,logseq,assets}

# Copy working Logseq config
cp migrate-org-to-obsidian/portable-profile/michael/obsidian-vault/logseq/config.edn ~/logseq-workspace/logseq/
```

#### 2.2 Migrate Data
```bash
# Move your working files from obsidian-vault (if still exists)
# Note: If obsidian-vault was already removed, skip this step
if [ -d "migrate-org-to-obsidian/portable-profile/michael/obsidian-vault/" ]; then
  cp -r migrate-org-to-obsidian/portable-profile/michael/obsidian-vault/pages/* ~/logseq-workspace/pages/
  cp -r migrate-org-to-obsidian/portable-profile/michael/obsidian-vault/journals/* ~/logseq-workspace/journals/
fi
```

#### 2.3 Update Emacs Configuration
Update `emacs_mrw_org_stuff.el`:
```elisp
(use-package org-roam
  :custom
  (org-roam-directory "~/logseq-workspace")
  ;; ... rest of configuration
)
```

#### 2.4 Remove Obsidian Migration Directory (Optional)
```bash
# Option A: Remove the entire migration directory if no longer needed
rm -rf migrate-org-to-obsidian/

# Option B: Keep the directory but remove only Obsidian-specific files
rm -rf migrate-org-to-obsidian/bin/org_roam_to_obsidian.sh*
rm -rf migrate-org-to-obsidian/elisp/org_roam_to_obsidian.el
```

### Phase 3: Cloud Sync Setup

#### 3.1 Option A: iCloud Sync (Recommended for Mobile)
```bash
# Create symlink to iCloud Logseq location
ln -sf "/Users/michael/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/org-roam-logseq" ~/logseq-workspace

# Update Emacs to use the symlinked location
# org-roam-directory will automatically point to iCloud location
```

#### 3.2 Option B: Dropbox/Google Drive Sync
```bash
# Move workspace to cloud sync directory
mv ~/logseq-workspace ~/Dropbox/logseq-workspace
# or
mv ~/logseq-workspace ~/Google\ Drive/logseq-workspace

# Update Emacs configuration accordingly
```

### Phase 4: Git Version Control

#### 4.1 Initialize Git Repository
```bash
cd ~/logseq-workspace
git init
echo "*.log" >> .gitignore
echo ".DS_Store" >> .gitignore
echo "logseq/bak/" >> .gitignore
echo "logseq/.recycle/" >> .gitignore
git add .
git commit -m "Initial Logseq workspace setup"
```

#### 4.2 Backup Strategy
```bash
# Create backup script
cat > ~/logseq-workspace/backup.sh << 'EOF'
#!/bin/bash
cd ~/logseq-workspace
git add .
git commit -m "Auto-backup $(date)"
git push origin main
EOF
chmod +x ~/logseq-workspace/backup.sh
```

## Recommended Practices

### Emacs Configuration Best Practices

#### 1. Use-Package Organization
```elisp
;; Group related packages together
(use-package org
  :ensure t
  :custom
  ;; All customizations in one place
  (org-babel-load-languages '((emacs-lisp . t) (shell . t) (python . t)))
  (org-babel-python-command "python3")
  :config
  ;; All configuration in one place
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
  :bind
  ;; All keybindings in one place
  (:map org-mode-map
        ("M-S-<right>" . org-table-insert-column)
        ("M-S-<left>" . org-table-delete-column)))
```

#### 2. Org-Roam Configuration
```elisp
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/logseq-workspace")
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :target (file+head "pages/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("p" "person" plain
      "* ${title}  :Person:\n \n* Contact\n \n* Organizations\n-\n* People\n-\n* Notes\n%?\n \n%T Created\n \n"
      :target (file+head "pages/%<%Y%m%d%H%M%S>-person_${slug}.org" "#+title: ${title}\n")
      :unarrowed t)))
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n l" . org-roam-buffer-toggle))
  :config
  (org-roam-db-autosync-mode))
```

#### 3. Logseq Integration
```elisp
(use-package org-roam-logseq
  :disabled t  ; Disable if not using org-roam-logseq package
  :after org-roam
  :config
  (setq bill/logseq-folder (f-expand (f-join org-roam-directory "")))
  (setq bill/logseq-pages (f-expand (f-join bill/logseq-folder "pages")))
  (setq bill/logseq-journals (f-expand (f-join bill/logseq-folder "journals"))))
```

### File Organization Best Practices

#### 1. Directory Structure
```
~/logseq-workspace/
├── pages/           # Main notes and pages
│   ├── People/      # Person notes
│   ├── Projects/    # Project notes
│   ├── Organizations/ # Organization notes
│   └── ...
├── journals/        # Daily journal entries
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
- [ ] Create clean Logseq workspace
- [ ] Migrate data from obsidian-vault
- [ ] Update Emacs configuration
- [ ] Set up cloud sync
- [ ] Initialize git repository
- [ ] Test Emacs integration
- [ ] Test mobile sync

### Post-Migration
- [ ] Verify all notes are accessible
- [ ] Test org-roam functionality
- [ ] Test mobile app sync
- [ ] Update any scripts or automation
- [ ] Document new setup

## Troubleshooting

### Common Issues

#### 1. Permission Denied on iCloud
- Use Finder to access iCloud Logseq folder
- Grant full disk access to terminal/emacs
- Consider using local directory with manual sync

#### 2. Org-Roam Database Issues
```elisp
;; Reset org-roam database if needed
(org-roam-db-clear-all)
(org-roam-db-sync)
```

#### 3. Logseq Sync Issues
- Check iCloud storage space
- Verify Logseq app permissions
- Restart Logseq app and sync

### Performance Optimization

#### 1. Large File Handling
```elisp
;; Limit org-roam to specific file patterns
(setq org-roam-file-extensions '("org"))
(setq org-roam-file-exclude-regexp "\\(?:^\\|\/\)\\(?:\\..*\\|.*~\\|.*#.*#\\)$")
```

#### 2. Database Optimization
```elisp
;; Periodic database cleanup
(defun my/org-roam-cleanup ()
  (interactive)
  (org-roam-db-clear-all)
  (org-roam-db-sync))
```

## Conclusion

This migration plan provides a clean, simplified setup that:
- Removes all Obsidian complexity
- Establishes a single source of truth for notes
- Enables seamless Emacs and mobile integration
- Provides proper version control and backup
- Follows best practices for maintainability

The key is to start with a clean slate and build up the functionality you actually need, rather than maintaining compatibility with tools you no longer use.
