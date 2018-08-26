;;; init.el --- Yi Zhenfei's emacs configuration
;;; Commentary:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrap package system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
;; Setup package repositories
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")
        ("elpy" . "https://jorgenschaefer.github.io/packages/")
        )
      )
;; Initialize package system but don't load all the packages
(package-initialize nil)
(setq package-enable-at-startup nil)
(unless package-archive-contents (package-refresh-contents))
;; Install use-package if necessary
(unless (package-installed-p 'use-package) (package-install 'use-package))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Common
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Custom file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Misc
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(blink-cursor-mode -1)
(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-bar-mode -1)))

;; Line number
(global-linum-mode t)
(unless window-system
  (add-hook 'linum-before-numbering-hook
            (lambda ()
              (setq-local linum-format-fmt
                          (let ((w (length (number-to-string
                                            (count-lines (point-min) (point-max))))))
                            (concat "%" (number-to-string w) "d"))))))

(defun linum-format-func (line)
  (concat
   (propertize (format linum-format-fmt line) 'face 'linum)
   (propertize " " 'face 'mode-line)))

(unless window-system
    (setq linum-format 'linum-format-func))

;; Theme
(use-package tangotango-theme
  :ensure t
  :init
;  (load-theme 'tangotango t)
  )

;; Powerline
(require 'powerline)
(powerline-my-theme)

;; UTF-8
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq current-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(setenv "LC_CTYPE" "UTF-8")

;; Backup file settings
(setq
 backup-by-coping t
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)
;; Save directory
(push (cons "." "~/.saves") backup-directory-alist)

;; Helm
(use-package helm
  :ensure t
  :config
  (require 'helm)
  (require 'helm-config)
  ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
  ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
  ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
  (global-set-key (kbd "C-c h") 'helm-command-prefix)
  (global-unset-key (kbd "C-x c"))
  ;; rebind tab to run persistent action
  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
  ;; make TAB work in terminal
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
  ;; list actions using C-z
  (define-key helm-map (kbd "C-z") 'helm-select-action)
  ;; Enable Helm for vairous scenarios
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x b") 'helm-mini)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  ;; Enable fuzzy matching
  (setq
   helm-M-x-fuzzy-match t
   helm-semantic-fuzzy-match t
   helm-imenu-fuzzy-match t
   helm-buffers-fuzzy-matching t
   helm-recentf-fuzzy-match t)
  (setq
   ;; open helm buffer inside current window, not occupy whole other window
   helm-split-window-in-side-p t
   ;; move to end or beginning of source when reaching top or bottom of source
   helm-move-to-line-cycle-in-source t
   ;;search for library in `require' and `declare-function' sexp
   helm-ff-search-library-in-sexp t
   ;; scroll 20 lines other window using M-<next>/M-<prior>
   helm-scroll-amount 20
   helm-ff-file-name-history-use-recentf t
   helm-echo-input-in-header-line t)
  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 50)
  (helm-autoresize-mode 1)
  (helm-mode 1)
  )

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Programming
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; yasnippet
(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.yasnippet/snippets"))
  (yas-global-mode 1)
  (global-set-key (kbd "M-n") 'yas-insert-snippet)
  )

;; Projectile
;; C-c p f
(use-package projectile
  :ensure t
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'helm)
  (setq projectile-switch-project-action 'helm-projectile)
  )

;; Company
(use-package company
  :ensure t
  :config
  (progn
    ;; Enable company mode in every programming mode
    (add-hook 'prog-mode-hook 'company-mode)
    ;; Set backends for company
    (setq-default
     company-backends
;;     '(company-rtags company-keywords)
     '(company-capf company-keywords))
    ;; Immediately auto compelete (no delay: 0)
    (setq company-idle-delay 0.5)
    ;; Auto complete after 1 char is entered
    (setq company-minimum-prefix-length 2)
    (setq company-show-numbers t)
    )
  )

;; Flycheck
(use-package flycheck
  :ensure t
  :config
  ;(add-hook 'prog-mode-hook 'flycheck-mode)
  )

;; Indentation
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(global-set-key (kbd "RET") 'newline-and-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C/C++
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CC mode
(setq-default c-basic-offset 4)
(defun my-c-setup ()
  (c-set-offset 'innamespace [0]))
(add-hook 'c++-mode-hook 'my-c-setup)

;; RTags
(use-package rtags
  :ensure t
  :config
  (progn
    ;; Start rdm when entering C/C++ mode
    ;; We are using sandbox mode, so disable the hook
    ;; (add-hook 'c-mode-common-hook 'rtags-start-process-unless-running)
    ;; (add-hook 'c++-mode-common-hook 'rtags-start-process-unless-running)
    ;; Enable completion
    (setq rtags-completions-enabled t)
    (setq rtags-autostart-diagnostics t)
    ;; Keybindings
    (define-key c-mode-base-map (kbd "M-.")
      (function rtags-find-symbol-at-point))
    (define-key c-mode-base-map (kbd "M-,")
      (function rtags-find-references-at-point))
    ;; TODO(Yi Zhenfei): Should I move this to somewhere else?
    (define-key c-mode-base-map (kbd "<C-tab>") (function company-complete))
    (rtags-enable-standard-keybindings)
    ;; Integration with helm
    (require 'helm-rtags)
    ;;    (setq rtags-use-helm t)
    (setq rtags-display-result-backend 'helm)
    (push 'company-rtags company-backends)
    ;; Integration with flycheck
    (require 'flycheck-rtags)
    (defun my-flycheck-rtags-setup()
      (flycheck-select-checker 'rtags)
      ;; RTags creates more accurate overlays
      (setq-local flycheck-highlighting-mode nil)
      (setq-local flycheck-check-syntax-automatically nil))
    (add-hook 'c-mode-common-hook #'my-flycheck-rtags-setup)
    )
  )

;; Using sandbox of rtags
(defun get-sbroot-for-dir (dir)
  "Find sandbox root of file for rtags"
  (if (or (not dir) (not (file-accessible-directory-p dir)) (string= dir "/"))
      nil
    (if (file-accessible-directory-p (concat dir ".rtags"))
        dir
      (get-sbroot-for-dir (file-name-directory (directory-file-name dir)))))
  )

(defun get-sbroot-for-buffer ()
  "Find sandbox root of buffer for rtags"
  (let ((f (buffer-file-name (current-buffer))))
    (if (stringp f)
        (get-sbroot-for-dir
         (file-name-directory
          (directory-file-name f)))
      nil)))

(add-hook 'find-file-hook
          (lambda ()
            (if (= (length rtags-socket-file) 0)
                (let ((sbroot (if (buffer-file-name) (get-sbroot-for-buffer) nil))
                      (socket-file nil))
                  (when sbroot
                    (setq socket-file (concat sbroot ".rtags/rdm.socket"))
                    (if (file-exists-p socket-file)
                        (setq rtags-socket-file socket-file)))))))

;; ycmd
(use-package ycmd
  :ensure t
  :config
  (add-hook 'c-mode-hook 'ycmd-mode)
  (add-hook 'c++-mode-hook 'ycmd-mode)
  (set-variable 'ycmd-server-command
                `("python", (file-truename "~/.emacs.d/ycmd/ycmd/")))
  (setq ycmd-extra-conf-handler 'load))

(use-package company-ycmd
  :ensure t
  :config (company-ycmd-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; switch window
(require 'window-numbering)
(window-numbering-mode 1)

;; 中文换行
(add-hook 'org-mode-hook
          (lambda () (setq truncate-lines nil))) 

;; org-mode支持导出markdown
(require 'ox-md nil t)

;; 行后插入行
;(global-set-key (kbd \"C-c S <RET>\")
;                '(lambda ()
;                   (interactive)
;                   (end-of-line)
;                   (newline)
;                   (previous-line)
;                   ))

;; 行前插入行
(global-set-key (kbd "C-c <RET>")
                '(lambda ()
                   (interactive)
                   (beginning-of-line)
                   (newline)
                   (previous-line)
                   ))

;; 交换buffer位置
;;(require 'buffer-move)
;;(global-set-key (kbd "<C-up>")     'buf-move-up)
;;(global-set-key (kbd "<C-down>")   'buf-move-down)

;;(global-set-key (kbd "<C-left>")   'buf-move-left)
;;(global-set-key (kbd "<C-right>")  'buf-move-right)

(require 'windcycle)
;;; init.el ends here
