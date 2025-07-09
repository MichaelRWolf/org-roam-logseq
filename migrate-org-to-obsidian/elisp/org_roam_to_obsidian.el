;;; org-roam-to-obsidian.el --- Export org files to Obsidian-compatible Markdown (GitHub Flavored)
;;; Commentary:
;; This package provides functionality to export org files to Obsidian-compatible
;; Markdown format using GitHub Flavored Markdown (GFM).
;;
;; Requirements:
;; - ox-gfm
;;
;; Usage:
;; (org-export-obsidian-file "path/to/note.org" "path/to/destination")
;; (org-export-all-to-obsidian "path/to/destination")
;;; Code:

;; Debug: Show load-file-name
(message "Loading org_roam_to_obsidian.el from: %s" load-file-name)

;; Add our elisp directory to load path
(add-to-list 'load-path (file-name-directory load-file-name))

;; Load required packages
(require 'org)
(require 'ox-gfm)

(defcustom org-export-obsidian-show-progress t
  "Whether to show progress during batch export."
  :type 'boolean
  :group 'org-export-obsidian)

(defun org-export-obsidian-file (orgfile destdir)
  "Export ORGFILE to DESTDIR with .md extension using ox-gfm.
ORGFILE should be a path to an org file.
DESTDIR should be a directory where the markdown files will be saved.
Returns t if successful, nil otherwise."
  (unless (file-exists-p orgfile)
    (error "Source file does not exist: %s" orgfile))
  (unless (file-writable-p destdir)
    (error "Destination directory is not writable: %s" destdir))
  
  (let* ((absfile (expand-file-name orgfile))
         (srcdir (file-name-directory absfile))
         (relpath (file-name-sans-extension (file-relative-name absfile srcdir)))
         (mdfile (expand-file-name (concat relpath ".md") destdir)))
    (condition-case err
        (progn
          (make-directory (file-name-directory mdfile) :parents)
          (with-current-buffer (find-file-noselect absfile)
            (org-export-to-file 'gfm mdfile nil nil nil t))
          (message "Exported: %s" mdfile)
          t)
      (error
       (message "Error exporting %s: %s" orgfile (error-message-string err))
       nil))))

(defun org-export-all-to-obsidian (srcdir destdir)
  "Export all .org files under SRCDIR to DESTDIR.
Shows progress if `org-export-obsidian-show-progress' is non-nil."
  (interactive "DExport all org files to directory: ")
  (unless (file-exists-p srcdir)
    (error "Source directory does not exist: %s" srcdir))
  
  (let ((files (directory-files-recursively srcdir "\\.org$"))
        (total (length files))
        (count 0)
        (success 0))
    (dolist (file files)
      (setq count (1+ count))
      (when org-export-obsidian-show-progress
        (message "Exporting %d/%d: %s" count total file))
      (when (org-export-obsidian-file file destdir)
        (setq success (1+ success))))
    (message "Export complete: %d/%d files exported successfully" success total)))

(provide 'org-export-obsidian)
;;; org-export-obsidian.el ends here
