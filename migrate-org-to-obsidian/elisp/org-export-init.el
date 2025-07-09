;;; org-export-init.el --- Initialize environment for org-roam export

;; Debug: Show load-file-name
(message "Loading org-export-init.el from: %s" load-file-name)

;; Add our elisp directory to load path
(add-to-list 'load-path (expand-file-name "elisp" (file-name-directory load-file-name)))

;; Load Org and its dependencies
(require 'org)
(require 'org-element)
(require 'ox)

;; Load org-roam
(use-package org-roam
  :ensure t
  :pin "melpa"
  :defer nil)

;; Set org-roam-directory from environment variable or default
(setq org-roam-directory (or (getenv "ORG_ROAM_DIRECTORY") "~/org-roam"))

;; Disable org-roam database sync for now
;; (org-roam-db-autosync-mode) 