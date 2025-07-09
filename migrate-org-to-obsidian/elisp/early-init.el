;; Set up package archives
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")))

;; Initialize package system
(package-initialize)

;; Find the latest Org version in ELPA and add it to load-path
(let ((org-elpa-dir (car (directory-files "~/.emacs.d/elpa" t "^org-[0-9]"))))
  (when org-elpa-dir
    (add-to-list 'load-path (expand-file-name "lisp" org-elpa-dir) t)))

;; Disable built-in Org
(setq org-replace-disputed-keys t)

;; Ensure Org is loaded before any other packages
(require 'org)
(require 'org-element)
(require 'ox) 