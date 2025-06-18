;;; org-roam-to-obsidian.el --- Export org-roam notes to Obsidian-compatible Markdown (GitHub Flavored)
;;; Commentary:
;; This package provides functionality to export org-roam notes to Obsidian-compatible
;; Markdown format using GitHub Flavored Markdown (GFM).
;;
;; Requirements:
;; - org-roam
;; - ox-gfm
;;
;; Usage:
;; (org-roam-export-obsidian-file "path/to/note.org" "path/to/destination")
;; (org-roam-export-all-to-obsidian "path/to/destination")
;;; Code:

(require 'ox-gfm)
(require 'org-roam)

(defcustom org-roam-to-obsidian-show-progress t
  "Whether to show progress during batch export."
  :type 'boolean
  :group 'org-roam-to-obsidian)

(defun org-roam-export-obsidian-file (orgfile destdir)
  "Export ORGFILE to DESTDIR with .md extension using ox-gfm.
ORGFILE should be a path to an org file.
DESTDIR should be a directory where the markdown files will be saved.
Returns t if successful, nil otherwise."
  (unless (file-exists-p orgfile)
    (error "Source file does not exist: %s" orgfile))
  (unless (file-writable-p destdir)
    (error "Destination directory is not writable: %s" destdir))
  
  (let* ((absfile (expand-file-name orgfile))
         (relpath (file-name-sans-extension (file-relative-name absfile org-roam-directory)))
         (mdfile (expand-file-name (concat relpath ".md") destdir)))
    (condition-case err
        (progn
          (make-directory (file-name-directory mdfile) :parents)
          (with-current-buffer (find-file-noselect absfile)
            (org-export-to-file 'gfm mdfile nil nil nil t))
          t)
      (error
       (message "Error exporting %s: %s" orgfile (error-message-string err))
       nil))))

(defun org-roam-export-all-to-obsidian (destdir)
  "Export all .org files under `org-roam-directory' to DESTDIR.
Shows progress if `org-roam-to-obsidian-show-progress' is non-nil."
  (interactive "DExport all org-roam notes to directory: ")
  (unless (file-exists-p org-roam-directory)
    (error "org-roam-directory does not exist: %s" org-roam-directory))
  
  (let ((files (directory-files-recursively org-roam-directory "\\.org$"))
        (total (length files))
        (count 0)
        (success 0))
    (dolist (file files)
      (setq count (1+ count))
      (when org-roam-to-obsidian-show-progress
        (message "Exporting %d/%d: %s" count total file))
      (when (org-roam-export-obsidian-file file destdir)
        (setq success (1+ success))))
    (message "Export complete: %d/%d files exported successfully" success total)))

(provide 'org-roam-to-obsidian)
;;; org-roam-to-obsidian.el ends here
