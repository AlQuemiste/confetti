;; MELPA package
(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)

(require 'use-package)

;; installed packages:
;-- use-package
;-- company
;-- magit
;-- wgrep
;-- flycheck
;-- cmake-mode
;-- doom-themes
;-- julia-mode
;-- julia-repl
;-- racket-mode
;-- yaml-mode

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
      initial-major-mode 'fundamental-mode
      scroll-bar-mode nil
      tool-bar-mode nil
      tooltip-mode nil ; disable tooltip appearance on mouse hover
      widget-image-enable nil ; show textual equivalent of widgets
)

;; editing
(setq-default tab-width 4)
(setq-default cmake-tab-width 4)
(setq-default indent-tabs-mode nil) ; use spaces instead of tabs for indentation
(setq-default scroll-step 1) ; scroll 1 line at a time
(setq-default line-move-visual t)
(setq-default fill-column 100)
(setq-default show-trailing-whitespace t)
(line-number-mode t)    ; show line numbers
(column-number-mode t)  ; show column numbers
;; show line numbers on the left
(global-display-line-numbers-mode t)
(setq linum-format "%4d ")  ; prettify line number format
;; visual-Line-Mode wraps a line right before the window edge, but ultimately they do not alter the buffer text
(global-visual-line-mode t)
;; set default cursor type in non-selected windows
(setq-default cursor-in-non-selected-windows 'hollow) ;'box)
(blink-cursor-mode t)

;; mark the locus in non-selected windows by a fringe-arrow
(setq-default next-error-highlight-no-select 'fringe-arrow)

;; enable/disable visible bell
(setq visible-bell nil)

(fset 'yes-or-no-p 'y-or-n-p)  ; y-or-n-p makes answering questions faster

;; proper bell sound for Emacs
;; ref: <https://www.gnu.org/software/emacs/manual/html_node/efaq/Turning-the-volume-down.html>
;; add the following to `.bashrc` or `.xinitrc`:
;; xset b 2 1 200

;; ESC cancels all
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; turn on paren match highlighting
(show-paren-mode t)

(setq comment-inline-offset 2)

;; narrowing
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-defun  'disabled nil)
(put 'narrow-to-page   'disabled nil)

;; upper/lower case conversion
(put 'upcase-region   'disabled nil)
(put 'downcase-region 'disabled nil)

;; unset suspend key chord
(global-unset-key (kbd "C-z")) ; bound to `suspend-frame' by default

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

(use-package dabbrev
  :init
  (setq
   ;; control whether dabbrev searches should ignore case (nil means case is significant)
   dabbrev-case-fold-search nil
   ;; copy expansions verbatim; do match the case
   case-replace nil
   dabbrev-case-replace nil
   )
  )


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

;;--- Add dired-mode functions to open/view multiple files
(require 'dired )

;; dired
(setq dired-listing-switches "-agho --group-directories-first"
      delete-by-moving-to-trash t)

;; ignore case when using completion for file names
(setq read-file-name-completion-ignore-case t)

(defun my-dired-find-files ()
  "Open each of the marked files"
  (interactive)
  (mapc 'find-file (dired-get-marked-files))
  )

(defun my-dired-view-files ()
  "View each of the marked files"
  (interactive)
  (mapc 'view-file (dired-get-marked-files))
  )

(define-key dired-mode-map "F" 'my-dired-find-files)
(define-key dired-mode-map "V" 'my-dired-view-files)

;; abbreviation mode
;(setq-default abbrev-mode t)
;(load "~/.emacs.d/my_emacs_abbrev")

;; to up-case keywords automatically in f90-mode
;; < https://lists.gnu.org/archive/html/help-gnu-emacs/2003-05/msg01134.html >
; (setq f90-auto-keyword-case 'upcase-word)

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
(global-set-key (kbd "C-c @") 'compile)
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


; (use-package company
;   :ensure t
;   :diminish company-mode
;   ; bind to `C-.`
;   :bind (("C-." . company-complete))
;   :init
;   (add-hook 'after-init-hook #'global-company-mode)
;   )

; (use-package company-dabbrev
;   :init
;   (setq company-dabbrev-ignore-case nil
;         ; don't downcase dabbrev suggestions
;         company-dabbrev-downcase nil)
;   )

; (use-package company-dabbrev-code
;   :init
;   (setq company-dabbrev-code-modes t
;         company-dabbrev-code-ignore-case nil)
;   )

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

;; Use super + arrow keys to switch windows
;; https://stackoverflow.com/a/96540/3484761
(windmove-default-keybindings 'super)

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

; interpret and use ansi color codes in shell buffers
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-hook 'diff-mode-hook 'ansi-color-for-comint-mode-on)

;=== CC mode
;; newline indent for CC mode
(use-package cc-mode
  :config
  (progn
    (setq-default c-basic-offset 4)
    (setq c-default-style "linux")
    )
)

;; suppress indentation within C++ namespaces
(c-set-offset 'innamespace 0)

;; enable CamelCase-aware editing for all programming modes
(add-hook 'prog-mode-hook 'subword-mode)

;; column-enforce-mode in all source code modes: highlights text extending beyond a certain column.
; (add-hook 'prog-mode-hook 'column-enforce-mode)

;; highlight-indent-guides in all source code modes
;(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)

;; switch to specific buffers

(defun bury-then-switch-to-buffer (buffer)
  (bury-buffer (current-buffer))
  (switch-to-buffer buffer)
  )

(defun switch-to-scratch ()
  (interactive)
  (bury-then-switch-to-buffer "*scratch*")
  )

(defun switch-to-compilation ()
  (interactive)
  (bury-then-switch-to-buffer "*compilation*")
  )

(defun switch-to-shell ()
  (interactive)
  (bury-then-switch-to-buffer "*shell*")
  )

; (global-set-key (kbd "C-*") 'switch-to-scratch)
(global-set-key (kbd "C-c *") 'switch-to-compilation)
(global-set-key (kbd "C-c !") 'switch-to-shell)


;=== Compilation
;; interpret ANSI color codes in compilation buffers
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(setq
 compile-command "make -j8"
 compilation-scroll-output nil   ; ON = follow compilation output
 compilation-always-kill t     ; always kill a running compilation before starting a new one
 compilation-skip-threshold 2  ; next-error should only stop at errors
 electric-indent-mode t
 which-function-mode t
 read-file-name-completion-ignore-case t
 show-trailing-whitespace t  ; highlight trailing whitespace
 ;; history
 history-length 100   ; max length for minibuffer history vars
 history-delete-duplicates t
 )

;; the characters that whitespace-mode should highlight
; (setq whitespace-style '(tabs newline space-mark
;                          tab-mark newline-mark
;                          face lines-tail))

;; set default connection mode to SSH
(setq tramp-default-method "ssh")

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
   (setq git-commit-summary-max-length 80)
   (setq auto-revert-verbose t) ; report when a buffer has been reverted
   )

;; flycheck
(when (require 'flycheck nil :noerror)
  (global-flycheck-mode)
  )

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

;==== Abbrev
;; ref:
;; https://www.oreilly.com/library/view/learning-gnu-emacs/1565921526/ch04s04.html
;; http://ergoemacs.org/emacs/emacs_abbrev_mode_tutorial.html

;;; sample abbrev definitions
;; ref: https://emacs.stackexchange.com/a/14081

;; do not insert the expansion character when inserting abbrev
;; ref: https://www.emacswiki.org/emacs/AbbrevMode#h5o-7
(defun dont-insert-expansion-char ()  t)  ; "hook" function
(put 'dont-insert-expansion-char 'no-self-insert t)  ; the hook should have a "no-self-insert"-property set

(define-abbrev-table 'c++-mode-abbrev-table
  '(
    ("inc"    "#include <" dont-insert-expansion-char nil)
    ("inl"    "#include \"" dont-insert-expansion-char nil)
    ("IF"     "#if" nil)
    ("IFD"    "#ifdef" nil)
    ("IFN"    "#ifndef" nil)
    ("EL"     "#else //" nil)
    ("EIF"    "#endif //" nil)
    ("main2"  "int main(int argc, char* argv[])\n{\nreturn 0;\n}" dont-insert-expansion-char nil)
    ("main"  "int main()\n{\nreturn 0;\n}" dont-insert-expansion-char nil)
    ("el"     "else {\n}" dont-insert-expansion-char nil)
    ("elif"   "else if {\n}" dont-insert-expansion-char nil)
    ("whl"    "while() {\n}" dont-insert-expansion-char nil)
    ("prn"    "printf(\"\")" dont-insert-expansion-char nil)
    ("nmsp"   "namespace {\n} // namespace" dont-insert-expansion-char nil)
    ("qo"     "std::cout <<" nil)
    ("nd"     "std::endl" dont-insert-expansion-char nil)
    ("sz"     "std::size_t" nil)
    ("vc"     "std::vector" nil)
    ("st"     "std::string" nil)
    ("ct"     "const" nil)
    ("scast"  "static_cast<" dont-insert-expansion-char)
    ("uqp"    "std::unique_ptr<" dont-insert-expansion-char nil)
    ("mkuq"   "std::make_unique<" dont-insert-expansion-char nil)
    ("shp"    "std::make_unique<" dont-insert-expansion-char nil)
    ("mksh"   "std::make_unique<" dont-insert-expansion-char nil)
    ("dbgpr"  "std::cout << \"AN>> \" << __FILE__ << \", L\" <<  __LINE__ << \": \" << __FUNCTION__ << \":\\n\"\n<< std::endl;" dont-insert-expansion-char nil)
    )
  ; :regexp "\\(#`[0-9A-Za-z._-]+\\)"
  :system t
  :case-fixed t  ; case of the abbrev’s name is significant
  )

(setq-default abbrev-mode t)
(setq abbrev-file-name "~/.emacs.d/abbrev_defs")
(read-abbrev-file "~/.emacs.d/my_abbrev_defs.el")

;;===  CEDET configuration ===
;; ref: <http://alexott.net/en/writings/emacs-devenv/EmacsCedet.html>

;; Enable EDE (Project Management) features
(global-ede-mode t)

;; Semantic
(require 'semantic)

;; ref: https://writequit.org/denver-emacs/presentations/2017-02-21-semantic-mode.html
(setq semantic-default-submodes
      '(; perform semantic actions during idle time
        ;; global-semantic-idle-scheduler-mode
        ; use a semantic database of parsed tags
        ;; global-semanticdb-minor-mode
        ; decorate buffers with additional semantic information
        ;; global-semantic-decoration-mode
        ; highlight the name of the current tag (function, class, etc.)
        global-semantic-highlight-func-mode
        ; show the name of the function at the top in a sticky
        ;; global-semantic-stickyfunc-mode
        ; generate a summary of the current tag when idle
        global-semantic-idle-summary-mode
        ; show a breadcrumb of location during idle time
        global-semantic-idle-breadcrumbs-mode
        ; switch to recently changed tags with `semantic-mrub-switch-tags', or `C-x B'
        global-semantic-mru-bookmark-mode
        ; highligh local names that are the same as name of tag under cursor
        global-semantic-idle-local-symbol-highlight-mode
        ; display possible name completions in the idle time. Requires that global-semantic-idle-scheduler-mode was enabled
        global-semantic-idle-completions-mode
        ; activate CEDET's context menu that is bound to right mouse button
        global-cedet-m3-minor-mode
        )
      )

; (add-hook 'c-mode-hook 'semantic-mode)
; (add-hook 'python-mode-hook 'semantic-mode)

(add-hook 'prog-mode-hook 'semantic-mode)

;; (semantic-load-enable-excessive-code-helpers) ; Enable prototype help and smart completion

;; SRecode
;(global-srecode-minor-mode t) ; Enable template insertion menu

(require 'semantic/ia)

;; Semantic can automatically find directory of GCC and the include files
(require 'semantic/bovine/gcc)

(global-set-key [(control return)] 'semantic-ia-complete-symbol)
(global-set-key "\C-c?" 'semantic-ia-complete-symbol-menu)
(global-set-key "\C-c>" 'semantic-complete-analyze-inline)
(global-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
(global-set-key "\C-cd" 'semantic-ia-show-doc)
(global-set-key "\C-co" 'eassist-switch-h-cpp)
(global-set-key "\C-cm" 'eassist-list-methods)
(global-set-key "\C-c\C-r" 'semantic-symref)

;; (defun my-cedet-hook ()
;;   (local-set-key [(control return)] 'semantic-ia-complete-symbol)
;;   (local-set-key "\C-c?" 'semantic-ia-complete-symbol-menu)
;;   (local-set-key "\C-c>" 'semantic-complete-analyze-inline)
;;   (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
;;   (local-set-key "\C-cd" 'semantic-ia-show-doc)
;;   (local-set-key "\C-co" 'eassist-switch-h-cpp)
;;   (local-set-key "\C-cm" 'eassist-list-methods)
;;   (local-set-key "\C-c\C-r" 'semantic-symref)
;; )

;; (add-hook 'c-mode-hook 'my-cedet-hook)

(semantic-mode t)

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

(defalias 'lt 'load-theme)
(defalias 'dt 'disable-theme)

;;;======================================================================
(defun open-emacs-settings ()
  """ open Emacs configuration folder """
  (interactive)
  (dired "$HOME/.emacs.d/"))

(defun :my ()
  (interactive)
  (dired "/home/ammar/myfolder"))

(defun grc ()
  "Run C++-grep recursively from the directory of the current buffer or the default directory"
  (interactive)
  (let* (
         ;; current directory
         (dir_ (file-name-directory
                (or load-file-name buffer-file-name default-directory)))
         ;; add a list of excluded directories
         (excluded-dirs "build,3rdparty")
         (extensions "cpp,hpp,c,h")
         ;; build grep command
         (excluded (concat "--exclude-dir={" excluded-dirs "}"))
         (included (concat "--include=*.{" extensions "}"))
         (msg0 (concat included " " excluded " -e "))
         (msg0ln (+ 1 (length msg0)))
         (msg_ (concat msg0 "  -- " dir_))
         ;; ask user for the grep pattern
         (cmd_ (concat "grep --color -nHr "
                       (read-from-minibuffer "c++-grep: " (cons msg_ msg0ln)))
               )
         )
    ;--in--
    (grep cmd_)
    )
  )

;;-- pomodoro
;; use `org-time-set-timer` to set time
;; `org-timer-pause-or-contine`: pause/continue
;; `org-timer-stop`: stop

(require 'org)
; (setq org-clock-sound "/path/to/sound.wav") ; set `org-clock-sound'
(setq-default org-timer-default-timer "30") ; default time interval in minutes
