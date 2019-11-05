;;; package --- Summary
;;; Commentary:

;;; Code:

(defvar cargo-bin (expand-file-name "~/.cargo/bin"))
(defvar local-bin (expand-file-name "~/.local/bin"))
(defvar go-bin (expand-file-name "~/go/bin"))
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path cargo-bin)
(add-to-list 'exec-path local-bin)
(add-to-list 'exec-path go-bin)
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin:" cargo-bin local-bin go-bin))
(setenv "EDITOR" "emacsclient")


;; the package manager
(require 'package)
(setq
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                    ("org" . "http://orgmode.org/elpa/")
                    ("melpa" . "http://melpa.org/packages/")
                    ("melpa-stable" . "http://stable.melpa.org/packages/"))
 package-archive-priorities '(("melpa" . 1)))

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))

;; This is only needed once, near the top of the file
(eval-when-compile (require 'use-package))
(require 'use-package-ensure)
(setq
 ;; install package if not installed
 use-package-always-defer t
 use-package-always-ensure t)

;; auto update packages
(use-package auto-package-update
  :init
  (setq auto-package-update-delete-old-versions t)
  (auto-package-update-maybe))

(use-package diminish)

(use-package evil
  ;; Equivalent to (add-hook 'find-file-hook 'evil-normal-state)
  :hook (find-file . evil-normal-state)
  :bind
  ;; Equivalent to (define-key evil-normal-state-map (kbd "M-.") 'xref-find-definitions)
  (:map evil-normal-state-map
        ("M-." . xref-find-definitions)
        :map evil-visual-state-map
        ("f" . avy-goto-char)
        ("F" . avy-goto-word-1))
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-default-state 'emacs)
  (setq evil-disable-insert-state-bindings t)
  (evil-mode 1)
  )

(use-package undo-tree
  ;; Equivalent to (bind-key "s-z" 'undo-tree-undo)
  :bind (("s-z" . undo-tree-undo)
         ("s-Z" . undo-tree-redo))
  :diminish)

(use-package company
  :hook (after-init . global-company-mode)
  :diminish
  :init
  (setq company-idle-delay 0))

(use-package ivy
  :diminish
  :init
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  (ivy-mode 1))

(use-package counsel
  :diminish
  :init
  (counsel-mode 1))

(use-package swiper
  :init
  (global-set-key (kbd "C-s") 'swiper))


(use-package ag)

(use-package magit)
(use-package json-mode)
(use-package js2-mode)
(use-package haskell-mode)
(use-package dockerfile-mode)

(use-package pinentry
  :init
  (setenv "INSIDE_EMACS" (format "%s,comint" emacs-version))
  (pinentry-start)
  )

(use-package yasnippet
  :diminish
  :init (yas-global-mode 1))

(use-package projectile
  :diminish
  :bind
  (:map projectile-mode-map
        ("s-p" . projectile-command-map)
        ("s-[" . projectile-previous-project-buffer)
        ("s-]" . projectile-next-project-buffer)
        ("C-c p" . projectile-command-map))
  :init
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1)
  )
;;; ===========================================================
;;; ==================== Set up rust ==========================
;;; ===========================================================

;; You need to install rust LSP to get full support of Rust

(use-package rust-mode)

;;; ===========================================================
;;; ==================== Set up scala metals ==================
;;; ===========================================================

(use-package scala-mode
  :mode "\\.s\\(c\\|cala\\|bt\\)$")

(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map))

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :diminish
  :init (global-flycheck-mode))

(use-package lsp-mode
  :bind
  (:map lsp-mode-map ("M-?" . lsp-find-references))
  ;; Optional - enable lsp-mode automatically in scala files
  :hook ((scala-mode . lsp)
         (rust-mode . lsp)
         (go-mode . lsp))
  :config (setq lsp-prefer-flymake nil))

(use-package lsp-ui)

;; Add company-lsp backend for metals
(use-package company-lsp)

;;; ===========================================================
;;; ==================== Set up haskell ==========================
;;; ===========================================================

(use-package intero
  :init
  (add-hook 'haskell-mode-hook 'intero-mode))

;;; ===========================================================
;;; ===========================================================
;;; ===========================================================

;;; ===========================================================
;;; ==================== Set up go ==========================
;;; ===========================================================

(use-package go-mode)

;;; ===========================================================
;;; ===========================================================
;;; ===========================================================

(use-package neotree
  :init
  (setq projectile-switch-project-action 'neotree-projectile-action)
  (setq neo-autorefresh nil)
  (defalias 'dired 'neotree-dir))
;; ocaml support

(use-package tuareg)

(use-package flycheck-ocaml)

(use-package yaml-mode)

(use-package cql-mode)

(use-package avy
  :init
  (global-set-key (kbd "s-f") 'avy-goto-char)
  (global-set-key (kbd "s-F") 'avy-goto-word-1))

(use-package windmove
  :bind (("s-h" . windmove-left)
         ("s-j" . windmove-down)
         ("s-k" . windmove-up)
         ("s-l" . windmove-right)
         ))

(global-set-key (kbd "s-K") 'kill-current-buffer)

;; set default term to zsh
(use-package term
  :bind ("<s-return>" . ansi-term)
  :init
  (defvar my-term-shell "/usr/local/bin/zsh")
  (defadvice ansi-term (before force-bash)
    (interactive (list my-term-shell)))
  (ad-activate 'ansi-term)
  )

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer))

;; walk around xref-find-references fails with "Wrong type argument: hash-table-p, nil"
;; in lsp mode
(setq xref-prompt-for-identifier '(not xref-find-definitions
                                       xref-find-definitions-other-window
                                       xref-find-definitions-other-frame
                                       xref-find-references))

(defun find-user-init-file ()
  "Edit the `user-init-file', in another window."
  (interactive)
  (find-file-other-window user-init-file))
(global-set-key (kbd "s-,") 'find-user-init-file)

(setq custom-file "~/.emacs.d/custom.el")
(load-file custom-file)

(server-start)

;; responde y or n instead of yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

(provide 'init)
;;; init.el ends here
