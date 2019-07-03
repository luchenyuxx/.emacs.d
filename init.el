;;; package --- Summary
;;; Commentary:

;;; Code:

(add-to-list 'exec-path "/usr/local/bin")
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setenv "EDITOR" "emacsclient")

;; the package manager
(require 'package)
(setq
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                    ("org" . "http://orgmode.org/elpa/")
                    ("melpa" . "http://melpa.org/packages/")
                    ("melpa-stable" . "http://stable.melpa.org/packages/"))
 package-archive-priorities '(("melpa-stable" . 1)))

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
  :config
  (setq auto-package-update-delete-old-versions t)
  (auto-package-update-maybe))

(use-package diminish)

(use-package evil
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-default-state 'emacs)
  (setq evil-disable-insert-state-bindings t)
  (global-set-key (kbd "M-n") 'evil-complete-next)
  (global-set-key (kbd "M-p") 'evil-complete-previous)
  (global-set-key (kbd "C-=") 'evil-indent)
  (evil-mode 1)
  :config
  (add-hook 'find-file-hook 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "M-.") 'xref-find-definitions)
  (define-key evil-normal-state-map (kbd "f") 'avy-goto-char)
  (define-key evil-normal-state-map (kbd "F") 'avy-goto-word-1)
  (define-key evil-normal-state-map (kbd "/") 'swiper)
  (define-key evil-visual-state-map (kbd "f") 'avy-goto-char)
  (define-key evil-visual-state-map (kbd "F") 'avy-goto-word-1)
  )

(use-package undo-tree
  :diminish
  :init
  (global-set-key (kbd "s-z") 'undo-tree-undo)
  (global-set-key (kbd "s-Z") 'undo-tree-redo))

(use-package company
  :diminish
  :init
  (setq
   company-idle-delay 0))
(add-hook 'after-init-hook 'global-company-mode)

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

(use-package projectile
  :diminish
  :pin melpa-stable
  :init
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1)
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "s-[") 'projectile-previous-project-buffer)
  (define-key projectile-mode-map (kbd "s-]") 'projectile-next-project-buffer)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package ag)

(use-package magit)
(use-package json-mode)
(use-package scala-mode
  :mode "\\.s\\(cala\\|bt\\)$")
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map))
(use-package sbt-mode)
(use-package haskell-mode)
(use-package dockerfile-mode)

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :diminish
  :init (global-flycheck-mode))

(use-package lsp-mode
  :init (setq lsp-prefer-flymake nil))

(use-package lsp-ui)

;; Add company-lsp backend for metals
(use-package company-lsp)

(use-package neotree
  :init
  (setq projectile-switch-project-action 'neotree-projectile-action)
  (setq neo-autorefresh nil))
;; ocaml support

(use-package tuareg)

(use-package flycheck-ocaml)

(use-package yaml-mode)

(use-package cql-mode)

(use-package avy
  :init
  (global-set-key (kbd "s-f") 'avy-goto-char)
  (global-set-key (kbd "s-F") 'avy-goto-word-1))

(setq custom-file "~/.emacs.d/custom.el")
(load-file custom-file)

(global-set-key (kbd "s-h") 'windmove-left)
(global-set-key (kbd "s-j") 'windmove-down)
(global-set-key (kbd "s-k") 'windmove-up)
(global-set-key (kbd "s-l") 'windmove-right)
(global-set-key (kbd "s-K") 'kill-current-buffer)

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

(server-start)

;; responde y or n instead of yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; set default term to zsh
(defvar my-term-shell "/usr/local/bin/zsh")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)
(global-set-key (kbd "<s-return>") 'ansi-term)

(global-set-key (kbd "C-x C-b") 'ibuffer)

(provide 'init)
;;; init.el ends here
