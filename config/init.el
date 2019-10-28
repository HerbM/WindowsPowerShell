;; Use runemacs.exe to avoid locking up a cmd prompt for emacs
;; set as doskey, batch file, or Powershell alias etc.
;;     e=C:\emacs\bin\runemacs.exe $*
;;     ehome=cd /d C:\Users\Herb\AppData\Roaming\.emacs.d
;;     emacs=C:\emacs\bin\runemacs.exe $*
;;  ErgoEmacs https://www.emacswiki.org/emacs/ErgoMovementMode
;;  esdf-mode https://www.emacswiki.org/emacs/esdf-mode
;;  Do Re Mi https://www.emacswiki.org/emacs/DoReMi

;;; https://www.emacswiki.org/emacs/LaCarte  Add this and maybe Icicles????
;;; Ctrl-tab still doesn't work correctly (most recent used),nor Alt-F (menu items)
;;; Recent files has things that I didn't open

;;(servers-start)
;(load-file "~/.emacs.d/pc-mode.elc")
;(pc-mode 1)

;; ~/.emacs.d/init.el
;; Emacs tutorial:  C-h t

;;;;;;;;;  MEL [ ]  c:/Users/Herb/AppData/Roaming/.emacs.d/init.el
(require 'package)
  (package-initialize)
    (add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)
    (add-to-list 'package-archives '("melpa"        . "http://melpa.org/packages/") t)
    (add-to-list 'package-archives '("marmalade"    . "http://marmalade-repo.org/packages/") t)
    (add-to-list 'package-archives '("org"          .  "http://orgmode.org/elpa/") t)
    (add-to-list 'package-archives '("gnu"          . "https://elpa.gnu.org/packages/") t)

;;; M-x package-refresh-contents
;;; list-packages

;;; ;;; better-defaults  ;;; bunch of crap turning off menus etc.
(defvar my-packages '(projectile
                      clojure-mode
                      cider
                      helm-cider
                      clj-refactor
                      clojure-cheatsheet
                      inf-clojure
                      rainbow-delimiters
                      ))

;;;; (add-to-list 'load-path "/full-path-to/org-mode/lisp") ;; load the development version of org-mode upon emacs invocation.
(require 'org)
(require 'ob-clojure)

;;;Install yasnippet via the Emacs package manager.
;;;git clone http://github.com/swannodette/clojure-snippets ~/.emacs.d/snippets/clojure-mode
;;;Or whatever location you prefer. Then In your .emacs you should have something like the following

(when (require 'yasnippet nil 'noerror)
  (progn
    (yas/load-directory "~/.emacs.d/snippets")))



;(inf-clojure-minor-mode)
;;;(add-hook 'cider-repl-mode-hook #'subword-mode)
(add-hook 'cider-repl-mode-hook #'paredit-mode) ; in the REPL buffer as well:
;; Smartparens
;  smartparens is an excellent alternative to paredit. Many Clojure hackers have
;  adopted it recently and you might want to give it a try as well.
;  To enable smartparens in the REPL buffer use the following code:
;(add-hook 'cider-repl-mode-hook #'smartparens-strict-mode)

; auto-complete

(dolist (p my-packages)
  (unless (package-installed-p p)
    (package-install p)))

; M-x cider-jack-in

;;;;;;;;;;;;;;;;;;;;   From Atos ;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 
   ; Various settings:
   (add-to-list 'load-path "~/.emacs.d/elisp") ;; Additional .el and .elc files can be placed here
   (setq inhibit-startup-message t)
   (setq inhibit-splash-screen t)       ;; Don't show initial Emacs-logo and info
   (transient-mark-mode 1)              ;; No region when it is not highlighted
   (setq cua-keep-region-after-copy t)  ;; Standard MS-Windows behaviour
   ;;;(require 'cygwin-mount)           ;; Let emacs recognize cygwin ...
   ;;;(cygwin-mount-activate)           ;; ...paths (e.g. /usr/local/lib)
   (setq-default line-spacing 1)        ;; Add 1 pixel between lines
   (recentf-mode)                       ;; Add menu-item "File--Open recent"
   ; Define some additional "native-Windows" keystrokes (^tab, Alt/F4, ^A, ^F, ^O,
   ; ^S, ^W) and redefine (some of) the overridden Emacs functions.
   (global-set-key [C-tab] 'other-window)
   (global-set-key "\C-a" 'mark-whole-buffer)
   (global-set-key "\C-f" 'isearch-forward)
   (global-set-key "\C-o" 'find-file)
   (global-set-key "\C-s" 'save-buffer)
   (global-set-key "\C-w" 'kill-this-buffer)
   (global-set-key (kbd "C-S-o") 'open-line)
   (global-set-key (kbd "C-S-w") 'kill-region)
   (define-key global-map (kbd "RET") 'newline-and-indent) ; For programming language modes
   (define-key isearch-mode-map "\C-f" 'isearch-repeat-forward)
 
   ; Default colours are too light (to see colour names do M-x list-colors-display
   ; and to see faces do M-x list-faces-display):
   ;;(set-face-foreground font-lock-type-face          "dark green")
   ;;(set-face-foreground font-lock-builtin-face       "Orchid4")
   ;;(set-face-foreground font-lock-constant-face      "CadetBlue4")
   ;;(set-face-foreground font-lock-keyword-face       "Purple4")
   ;;(set-face-foreground font-lock-string-face        "IndianRed4")
   ;;(set-face-foreground font-lock-variable-name-face "SaddleBrown")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(cua-mode t nil (cua-base))
 '(custom-enabled-themes (quote (deeper-blue)))
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(display-time-mode t)
 '(geiser-racket-binary "C:\\Program Files\\Racket\\Racket.exe")
 '(geiser-racket-collects (quote ("C:\\Program Files\\Racket\\collects")))
 '(geiser-racket-gracket-binary "C:\\Program Files\\Racket\\GRacket-text.exe")
 '(package-selected-packages
   (quote
    (paradox undo-tree sml-mode flycheck-clojure flycheck-color-mode-line flycheck-pos-tip ace-popup-menu ace-window adaptive-wrap adjust-parens ahk-mode alect-themes align-cljlet all anything-replace-string auto-yasnippet autobookmarks autopair buffer-stack bug-hunter datomic-snippets el-autoyas free-keys fsharp-mode helm-c-yasnippet helm-chrome helm-circe helm-clojuredocs helm-company helm-descbinds helm-describe-modes helm-dictionary helm-dired-history helm-dired-recent-dirs helm-firefox helm-flycheck helm-google helm-helm-commands helm-perldoc helm-pydoc helm-w32-launcher helm-wordnet javadoc-lookup jira jist moccur-edit mode-icons point-stack react-snippets ac-nrepl evalator evalator-clojure helm-cider-history rainbow-delimiters inf-clojure squiggly-clojure cider-hydra helm-cider clj-mode cljdoc clojars clojure-env clojure-here clojurescript-mode clomacs powerline powershell common-lisp-snippets company company-quickhelp org-journal org-linkany org-mobile-sync org-outlook worf solarized-theme gist bind-key discover discover-clj-refactor nrepl-discover which-key geiser racket-mode clj-refactor clojure-mode sequences helm-swoop cider cider-decompile cider-eval-sexp-fu cider-profile cider-spy 4clojure rainbow-identifiers rainbow-delimiters rainbow-blocks projectile clojure-snippets clojure-quick-repls clojure-mode-extra-font-locking clojure-cheatsheet cljr-helm circe ac-cider)))
 '(save-place-mode t)
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tool-bar-mode nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#001020" :foreground "WhiteSmoke" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "outline" :family "Consolas"))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "yellow"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "dark turquoise"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "lawn green"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "orange"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "hot pink"))))
 '(rainbow-delimiters-mismatched-face ((t (:inherit rainbow-delimiters-unmatched-face :inverse-video t :overline t :underline t))))
 '(rainbow-delimiters-unmatched-face ((t (:foreground "#E0A040" :inverse-video nil :overline nil :underline nil)))))
 
(require 'ido)
(ido-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun indent-region(numSpaces)
  (progn
    ; default to start and end of current line
    (setq regionStart (line-beginning-position))
    (setq regionEnd (line-end-position))

    ; if there's a selection, use that instead of the current line
    (when (use-region-p)
	(setq regionStart (region-beginning))
	(setq regionEnd (region-end))
    )

    (save-excursion ; restore the position afterwards           
	(goto-char regionStart) ; go to the start of region
	(setq start (line-beginning-position)) ; save the start of the line
	(goto-char regionEnd) ; go to the end of region
	(setq end (line-end-position)) ; save the end of the line

	(indent-rigidly start end numSpaces) ; indent between start and end
    	(setq deactivate-mark nil) ; restore the selected region
    )
  )
)
 
(defun untab-region (N)
  (interactive "p")
  (indent-region -2))
 
(defun tab-region (N)
  (interactive "p")
  (if (use-region-p)
      (indent-region 2) ; region was selected, call indent-region
      (insert "  "))) ; else insert four spaces as expected))
 
(global-set-key (kbd "<backtab>") 'untab-region)
(global-set-key (kbd "<tab>") 'tab-region)
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 (defun duplicate-line (arg)
    "Duplicate current line, leaving point in lower line."
    (interactive "*p")
    ;; save the point for undo
    (setq buffer-undo-list (cons (point) buffer-undo-list))
    ;; local variables for start and end of line
    (let ((bol (save-excursion (beginning-of-line) (point))) eol)
      (save-excursion
      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))
      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )
      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let
   (next-line arg))   ;; put the point in the lowest line and return

 
(global-set-key (kbd "C-d") 'duplicate-line)
;;;  TODO:  Kill line 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun move-text-internal (arg)
   (cond
    ((and mark-active transient-mark-mode)
     (if (> (point) (mark))
            (exchange-point-and-mark))
     (let ((column (current-column))
              (text (delete-and-extract-region (point) (mark))))
       (forward-line arg)
       (move-to-column column t)
       (set-mark (point))
       (insert text)
       (exchange-point-and-mark)
       (setq deactivate-mark nil)))
    (t
     (beginning-of-line)
     (when (or (> arg 0) (not (bobp)))
       (forward-line)
       (when (or (< arg 0) (not (eobp)))
            (transpose-lines arg))
       (forward-line -1)))))
 
(defun move-text-down (arg)
   "Move region (transient-mark-mode active) or current line arg lines down."
   (interactive "*p")
   (move-text-internal arg))
 
(defun move-text-up (arg)
   "Move region (transient-mark-mode active) or current line arg lines up."
   (interactive "*p")
   (move-text-internal (- arg)))
 
(global-set-key [\C-\S-up] 'move-text-up)     ;; move line or region live
(global-set-key [\C-\S-down] 'move-text-down) ;; move line or region live 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
(autoload 'buffer-stack-down          "buffer-stack" nil t)
(autoload 'buffer-stack-up            "buffer-stack" nil t)
(autoload 'buffer-stack-bury-and-kill "buffer-stack" nil t)
(autoload 'buffer-stack-bury          "buffer-stack" nil t)
(eval-after-load                      "buffer-stack" '(require 'buffer-stack-suppl))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key [(f10)]         'buffer-stack-bury)
(global-set-key [(control f10)] 'buffer-stack-bury-and-kill)
(global-set-key [(\C-\S-tab)]   'buffer-stack-down)
(global-set-key [(\C-tab)]      'buffer-stack-up)
(global-set-key [(shift f10)]   'buffer-stack-bury-thru-all)
(global-set-key [(shift f9)]    'buffer-stack-down-thru-all)
(global-set-key [(shift f11)]   'buffer-stack-up-thru-all)  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-key cua-global-keymap [C-M-return] 'cua-rectangle-mark-mode) ;; keep CUA rectangle marking
(define-key cua-global-keymap [C-return] nil)  ;; undefine C-return in CUA or new binding won't work
(global-set-key (kbd "<C-return>")   'newline) ;; new binding for ordinary newline (no indent)
;;; check if this needs to be: emulation or translation maps, not global,...

(when (fboundp 'menu-bar-mode)   (menu-bar-mode   1))  ; turn on menus 
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode 1))  ; turn on scroll bars 
(when (fboundp 'tool-bar-mode)   (tool-bar-mode  -1))  ; no tool-bar, turn off
(global-linum-mode 1)
(ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)

(setq buffer-stack-show-position 'buffer-stack-show-position-buffers)

(autoload 'buffer-stack-down          "buffer-stack"  nil t)
(autoload 'buffer-stack-up            "buffer-stack"  nil t)
(autoload 'buffer-stack-bury-and-kill "buffer-stack"  nil t)
(autoload 'buffer-stack-bury          "buffer-stack"  nil t)
(eval-after-load "buffer-stack" '(require 'buffer-stack-suppl))

;(global-set-key (kbd "<C-tab>")   'buffer-stack-down)
;(global-set-key (kbd "<C-S-tab>") 'buffer-stack-up)

(global-set-key (kbd "<C-tab>")   'next-buffer)
(global-set-key (kbd "<C-S-tab>") 'previous-buffer)
(global-set-key (kbd "M-f")     'menu-bar-open)
(global-set-key (kbd "M-C-S")     'helm-swoop)

(require 'powershell-mode)

(add-to-list 'auto-mode-alist '("\\.py\\'" .   python-mode))
(add-to-list 'auto-mode-alist '("\\.ps1\\'" .  powershell--mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell--mode))

(setq which-key-popup-type 'minibuffer)
(defvar which-key-mode 1)
(setq minibuffer-message-timeout 12)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(setq cider-cljs-lein-repl
      "(do (require 'figwheel-sidecar.repl-api)
           (figwheel-sidecar.repl-api/start-figwheel!)
           (figwheel-sidecar.repl-api/cljs-repl))")

(global-set-key (kbd "M-x") 'helm-M-x)

;; (global-font-lock-mode t)

;;;(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
;;;M-x customize-group rainbow-delimiters

;;;  Open recent is still screwed up -- too many files
;;;  Cycle buffers is still not right -- too many files and doesn't do most recent correctly
;;;  Learn search -- it's on the menu  M-%    ?  ! does all
;;;  Fix or learn clojure cheatsheet and grimoire
;;;  learn helm
;;;  learn org mode
;;;  fix powershell-mode
;;;  fix undo or learn it the emacs way (both?)
;;;  use and clean up paredit, smartparens, or paxedit
;;;  squiggly?  flycheck?
;;;  which-key https://github.com/justbur/emacs-which-key
;;;  move line/block won't move to last line of file (can't add line?)
;;;
;;;  parinfer ???
;;;
;;;
;;;  http://ftp.newartisans.com/pub/git.from.bottom.up.pdf (http://ikke.info/git.from.bottom.up.pdf)  http://git-scm.com/book 
;;;  datamic
;;;  untangled, Om Next
;;;
;;;  ClojureScript - FigWheel
;;;
;;;
;;;  ClojureClr targeting Unity
;;;
;;;  QuickCheck/TestCheck/Spec ? (Schema)
;;;
(add-hook 'sml-mode-hook
	  (lambda () (setq indent-tabs-mode t tab-width 4 sml-indent-level 4)))
(setq sml-program-name "sml")

;; Bind keys as follows in your .emacs:
;;
   (require 'bind-key)
;;
;;   (bind-key "C-c x" 'my-ctrl-c-x-command)
;;
;; If the keybinding argument is a vector, it is passed straight to
;; `define-key', so remapping a key with `[remap COMMAND]' works as
;; expected:
;;
;;   (bind-key [remap original-ctrl-c-x-command] 'my-ctrl-c-x-command)
;;
;; If you want the keybinding to override all minor modes that may also bind
;; the same key, use the `bind-key*' form:
;;
;;   (bind-key* "<C-return>" 'other-window)
;;
;; If you want to rebind a key only in a particular keymap, use:
;;
;;   (bind-key "C-c x" 'my-ctrl-c-x-command some-other-mode-map)
;;
;; To unbind a key within a keymap (for example, to stop your favorite major
;; mode from changing a binding that you don't want to override everywhere),
;; use `unbind-key':
;;
;;   (unbind-key "C-c x" some-other-mode-map)
;;
;; To bind multiple keys at once, or set up a prefix map, a `bind-keys' macro
;; is provided.  It accepts keyword arguments, please see its documentation
;; for a detailed description.
;;
;; To add keys into a specific map, use :map argument
;;
;;    (bind-keys :map dired-mode-map
;;               ("o" . dired-omit-mode)
;;               ("a" . some-custom-dired-function))
;;
;; To set up a prefix map, use `:prefix-map' and `:prefix' arguments (both are
;; required)
;;
;;    (bind-keys :prefix-map my-customize-prefix-map
;;               :prefix "C-c c"
;;               ("f" . customize-face)
;;               ("v" . customize-variable))
;;
;; You can combine all the keywords together.  Additionally,
;; `:prefix-docstring' can be specified to set documentation of created
;; `:prefix-map' variable.
;;
;; To bind multiple keys in a `bind-key*' way (to be sure that your bindings
;; will not be overridden by other modes), you may use `bind-keys*' macro:
;;
;;    (bind-keys*
;;     ("C-o" . other-window)
;;     ("C-M-n" . forward-page)
;;     ("C-M-p" . backward-page))
;;
;; After Emacs loads, you can see a summary of all your personal keybindings
;; currently in effect with this command:
;;
;;   M-x describe-personal-keybindings
;;
;; This display will tell you if you've overriden a default keybinding, and
;; what the default was.  Also, it will tell you if the key was rebound after
;; your binding it with `bind-key', and what it was rebound it to.

;;; Code: ---->  C:\Users\Herb\AppData\Roaming\.emacs.d\elisp\bind-key.el

;;; Ch Help k->key,c->command, a->apropos, 
