;; MELPA package
(require 'package) ;;
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

;; to declutter mode line
(when (require 'delight nil :noerror)
  (delight '((abbrev-mode " Abv" abbrev)
             (eldoc-mode nil eldoc)
             (company-mode " Co" company)
             (overwrite-mode " Ov" t)
             (visual-line-mode nil simple)
             (emacs-lisp-mode "eLisp" :major)))
  )

;; minimal UI
(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'fundamental-mode)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)

;; disable backup files
(setq auto-save-default nil) ; stop creating #autosave# files
;; backup
; (setq make-backup-files nil) ; stop creating backup~ files
;; avoid littering the user's filesystem with backups
(setq
   backup-by-copying t  ; don't clobber symlinks
   backup-directory-alist
    '((".*" . "~/.emacs.d/saves/")) ; don't litter filesystem tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t  ; use versioned backups
   )

;; Enable visible bell
(setq visible-bell t)

(line-number-mode t)    ; makes the line number show up
(column-number-mode t)  ; makes the column number show up
(fset 'yes-or-no-p 'y-or-n-p)  ; y-or-n-p makes answering questions faster

;; show line numbers on the left
(global-display-line-numbers-mode t)
(setq linum-format "%4d ")  ; prettify line number format

;; set default cursor type in non-selected windows
(setq-default cursor-in-non-selected-windows 'hollow) ;'box)
(blink-cursor-mode t)

;; mark the locus in non-selected windows by a fringe-arrow
(setq-default next-error-highlight-no-select 'fringe-arrow)

;; Visual-Line-Mode wraps a line right before the window edge, but ultimately they do not alter the buffer text.
(global-visual-line-mode t)

;; copy expansions verbatim; do not match the case
;; (setq dabbrev-case-replace nil)
;; (setq case-replace nil)

;; turn on paren match highlighting
(show-paren-mode 1)

(setq comment-inline-offset 2)

;; activate Savehist mode to save only minibuffer histories
(savehist-mode 0)

(setq custom-theme-allow-multiple-selections nil)

;; (add-to-list 'default-frame-alist
;;              '(font . "Inconsolata-13"))

(add-to-list 'default-frame-alist
             '(font . "Inconsolata-16"))


;; delete trailing whitespace before save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; automatically kill running processes on exit
(setq confirm-kill-processes nil)

;; column-enforce-mode in all source code modes: highlights text extending beyond a certain column.
;;(add-hook 'prog-mode-hook 'column-enforce-mode)

;; highlight-indent-guides in all source code modes
;; (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)

;; kill or copy the line point is on with a single keystroke:
;; C-w kills the current line
;; M-w copies the current line
;; < http://emacs.stackexchange.com/a/2348/9251 >
(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (list (line-beginning-position) (line-beginning-position 2)))))

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position) (line-beginning-position 2)))))

;; abbreviation mode
;(setq-default abbrev-mode t)
;(load "~/.emacs.d/my_emacs_abbrev")

;; to up-case keywords automatically in f90-mode
;; < https://lists.gnu.org/archive/html/help-gnu-emacs/2003-05/msg01134.html >
(setq f90-auto-keyword-case 'upcase-word)

;; keyboard shortcuts
;; source < http://stackoverflow.com/a/154146/3484761 >
(global-set-key [(control \,)] 'goto-line)
(global-set-key [(control \.)] 'call-last-kbd-macro)
(global-set-key [(control tab)] 'indent-region)
(global-set-key [(control j)] 'join-line)
;(global-set-key [f1] 'man)
;(global-set-key [f2] 'igrep-find)
;(global-set-key [f3] 'isearch-forward)
;(global-set-key [f4] 'next-error)
;(global-set-key [f5] 'gdb)
;(global-set-key [f6] 'compile)
;(global-set-key [f7] 'recompile)
;(global-set-key [f8] 'shell)
;(global-set-key [f9] 'find-next-matching-tag)
;(global-set-key [f11] 'list-buffers)
;(global-set-key [f12] 'shell)

;; inserting date
;; source < http://stackoverflow.com/a/2643094/3484761 >

(defun insertdate ()
  (interactive)
  (insert (format-time-string "%d-%m-%Y")))

(global-set-key [(f12)] 'insertdate)

;; custom themes
;; (add-to-list 'load-path "~/.emacs.d/themes/my-kaolin")
;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/my-kaolin")
;;(load-theme 'mytheme t)

;; AUCTeX
;(add-to-list 'load-path "~/.emacs.d/elpa/auctex-11.89")
;; (load "auctex.el" nil t t)
;; (load "preview.el" nil t t)

;; keep the braces from ever being inserted when AUCTeX inserts a macro
;; source: <http://tex.stackexchange.com/questions/51218>
(setq TeX-insert-braces nil)

;; code to insert \frac{}{}:
;; <https://gist.github.com/zmwangx/11199126>

(defun TeX-insert-fraction()
  "Insert \"frac{}{}\" and move point to after the first \"{\"."
  (interactive)
  (insert "\\frac{}{}")
  (backward-char 3)
)

(add-hook 'TeX-mode-hook
  '(
  lambda () (local-set-key (kbd "C-c /") 'TeX-insert-fraction)
  )
)

;; insert \sqrt{}
(defun TeX-insert-sqrt()
  (interactive)
  (insert "\\sqrt\{\}")
  (backward-char 1)
)

(add-hook 'TeX-mode-hook
  '(
  lambda () (local-set-key (kbd "C-c @") 'TeX-insert-sqrt)
  )
)

;; insert \sum_{}
(defun TeX-insert-sum()
  (interactive)
  (insert "\\sum_\{\}")
  (backward-char 1)
)

(add-hook 'TeX-mode-hook
  '(
  lambda () (local-set-key (kbd "C-c +") 'TeX-insert-sum)
  )
)

;; Cython mode
;(load "~/.emacs.d/cython-mode")

;; use company-mode in all buffers
(when (require 'company nil :noerror)
  (add-hook 'after-init-hook 'global-company-mode)

  (setq company-minimum-prefix-length 1
        company-idle-delay 0.2) ;; default is 0.2
  )

;; color in shell-command
;; https://stackoverflow.com/a/5821668
;(require 'ansi-color)

;; Indentation and buffer cleanup
;; This re-indents, untabifies, and cleans up whitespace.

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (untabify-buffer)
  (delete-trailing-whitespace))

(global-set-key (kbd "C-c C") 'cleanup-buffer)

;; YAML
;; Add additional file extensions that trigger yaml-mode.
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))

;; Haskell
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(defadvice display-message-or-buffer (before ansi-color activate)
  "Process ANSI color codes in shell output."
  (let ((buf (ad-get-arg 0)))
    (and (bufferp buf)
         (string= (buffer-name buf) "*Shell Command Output*")
         (with-current-buffer buf
           (ansi-color-apply-on-region (point-min) (point-max))))))

;; set Python shell interpreter for 'run-python'
(setq python-shell-interpreter "/usr/bin/python3")

;; Maxima
(add-to-list 'load-path "/usr/share/emacs/site-lisp/maxima/")

(autoload 'maxima-mode "maxima" "Maxima mode" t)
(autoload 'imaxima "imaxima" "Frontend for maxima with Image support" t)
(autoload 'maxima "maxima" "Maxima interaction" t)
(autoload 'imath-mode "imath" "Imath mode for math formula input" t)
(setq imaxima-use-maxima-mode-flag t)
(add-to-list 'auto-mode-alist '("\\.ma[cx]" . maxima-mode))
(setq imaxima-fnt-size "Large")

;; reStructuredText
(when (require 'rst nil :noerror)
  (setq auto-mode-alist
        (append '(("\\.md\\'" . rst-mode)
                  ("\\.rst\\'" . rst-mode)
                  ("\\.rest\\'" . rst-mode)) auto-mode-alist))
  )


;; SQL Upcase
 (when (require 'sql-upcase nil :noerror)
   (add-hook 'sql-mode-hook 'sql-upcase-mode)
   (add-hook 'sql-interactive-mode-hook 'sql-upcase-mode))

;; Magit
 (when (require 'magit nil :noerror)
   (global-set-key (kbd "C-x g") 'magit-status)
   )

;; flycheck
;; (require 'flycheck)
;; (global-flycheck-mode)

;; CMake
(setq auto-mode-alist
      (append
       '(("CMakeLists\\.txt\\'" . cmake-mode))
       '(("\\.cmake\\'" . cmake-mode))
       auto-mode-alist))

;; Telephone mode-line configuration
;; <https://github.com/dbordak/telephone-line>
;; (require 'telephone-line)
;; (setq telephone-line-primary-left-separator 'telephone-line-tan-left
;;       telephone-line-secondary-left-separator 'telephone-line-tan-hollow-left
;;       telephone-line-primary-right-separator 'telephone-line-tan-right
;;       telephone-line-secondary-right-separator 'telephone-line-tan-hollow-right)
;; (setq telephone-line-height 24
;;       telephone-line-evil-use-short-tag t)
;; (telephone-line-mode 1)



(when (require 'lsp-mode nil :noerror)
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
   (add-hook 'python-mode-hook #'lsp-deferred)
   )

;;;======================================================================
;;; provide save-as functionality without renaming the current buffer
;;; https://stackoverflow.com/a/5169028
(defun save-as (new-filename)
  (interactive "FFilename:")
  (write-region (point-min) (point-max) new-filename)
  (find-file-noselect new-filename))

;;;======================================================================
(defalias 'list-buffers 'ibuffer) ; always use ibuffer

(defalias 'lml 'list-matching-lines)
(defalias 'dml 'delete-matching-lines)
(defalias 'dnml 'delete-non-matching-lines)
(defalias 'dt 'delete-trailing-whitespace)

(defalias 'g 'grep)
(defalias 'gf 'grep-find)
(defalias 'fd 'find-dired)

(defalias 'rb 'revert-buffer)
(defalias 'lcd 'list-colors-display)

(defalias 'lf 'load-file)

;;;======================================================================
(defun open-emacs-settings ()
  """ open Emacs configuration folder """
  (interactive)
  (dired "$HOME/.emacs.d/"))
