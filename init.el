;;; init.el --- A lightweight, fast, simple and crude configuration -*- lexical-binding: t no-byte-compile: t -*-
;;
;; Copyright (C) 2022 Muqiu Han <muqiu-han@outlook.com>
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; A lightweight, fast, simple and crude configuration for GNU Emacs.
;;
;;
;;; Code:

;; ----------------------------------- Package config -----------------------------------

(require 'package)

(setq-default url-proxy-services
	      '(("no_proxy" . "^\\(localhost\\|10.*\\)")
		("http" . "127.0.0.1:7890")
		("https" . "127.0.0.1:7890"))
	      
	      is-graphics (display-graphic-p)

	      is-x11 (string-equal "x11" (getenv "XDG_SESSION_TYPE")))

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(defun require-package (&rest packages)
  (dolist (p packages)
    (unless (package-installed-p p)
      (condition-case nil (package-install p)
        (error
         (package-refresh-contents)
         (package-install p))))))

(require-package 'treemacs
		 'proof-general
		 'company
		 'company-coq
		 'markdown-mode
		 'dune-format
		 'darkroom
		 'doom-themes
		 'racket-mode
		 'utop
		 'which-key
		 'simple-modeline
		 'flycheck-ocaml
		 'flycheck
		 'tuareg
		 'window-numbering
		 'dune
		 'ocamlformat
		 'use-package
		 'magit
		 'beacon
		 'goto-line-preview
		 'youdao-dictionary)

(when is-x11
  (require-package 'xclip))

(if is-graphics
  (require-package 'flycheck-posframe
		   'treemacs-all-the-icons
		   'eldoc-box)
  (require-package 'flycheck-popup-tip))
		   

;; ----------------------------------- Basic config -----------------------------------
(menu-bar-mode -1)
(tool-bar-mode -1)

(when (display-graphic-p)
  (setq default-frame-alist '((internal-border-width . 5)
			      (vertical-scroll-bars)
			      (left-fringe . 0)
			      (right-fringe . 0)))

  (setq-default line-spacing 0.2
		cursor-type '(hbar . 5))

  (set-face-attribute 'default nil
		      :font "Consolas Ligaturized v3"
		      :weight 'bold
		      :height 140)

  (toggle-frame-maximized))

(global-auto-revert-mode 1)
(setq backup-directory-alist `(("." . "~/.saves"))
      gc-cons-threshold (* 50 1000 1000))

(load-theme 'doom-dark+ t)

;; ----------------------------------- config -----------------------------------

;; company
(use-package company
  :defer t
  :init (global-company-mode t))

;; line number
(use-package display-line-numbers
  :defer t

  :init
  (set-face-attribute 'line-number nil :italic nil)
  (set-face-attribute 'line-number-current-line nil :italic nil)
  
  :hook (prog-mode . display-line-numbers-mode))

;; Beacon
(use-package beacon
  :defer t
  :hook (after-init . beacon-mode)
  :config
  (setq beacon-color "#0f0"))

;; mode line
(use-package simple-modeline
  :defer t
  :hook (after-init . simple-modeline-mode))

;; xclip: easy to synchorize with the system clipboard
(use-package xclip
  :defer t
  :init
  (when (string-equal "x11" (getenv "XDG_SESSION_TYPE"))
    (xclip-mode)))

;; treemacs
(use-package treemacs
  :defer t
  :config
  (setq treemacs-width 35
	treemacs-indentation 2
	treemacs-position 'left
	treemacs-icon-tag-leaf "0")

  (dolist (face '(treemacs-root-face
                  treemacs-git-unmodified-face
                  treemacs-git-modified-face
                  treemacs-git-renamed-face
                  treemacs-git-ignored-face
                  treemacs-git-untracked-face
                  treemacs-git-added-face
                  treemacs-git-conflict-face
                  treemacs-directory-face
                  treemacs-directory-collapsed-face
                  treemacs-file-face
                  treemacs-tags-face))
    (set-face-attribute face nil
			:font (face-attribute 'default :font)
			:height 130))
  
  :init
  (when (display-graphic-p)
    (use-package treemacs-all-the-icons)
    (treemacs-load-theme "all-the-icons"))

  :bind (([f8]        . treemacs)
         ("M-RET"       . treemacs-select-window)
         ("C-x t t"   . treemacs)))

;; eldoc
(when (display-graphic-p)
  (use-package eldoc-mode
    :defer t
    :hook (eldoc-mode . eldoc-box-hover-at-point-mode)
    :config
    (use-package eldoc-box
      :config
      (set-face-attribute 'eldoc-box-border nil :background "#444")

      (set-face-attribute 'eldoc-box-body nil
			  :background (face-attribute 'default :background)))))

;; Flycheck
(use-package flycheck
  

;; Racket
(use-package racket-mode
  :defer t
  :hook (racket-mode . racket-xp-mode))

;; OCaml
(use-package tuareg
  :defer t
  :config
  (use-package merlin
    :hook ((tuareg-mode . merlin-mode)
	   (tuareg-mode . merlin-eldoc-setup)
	   (tuareg-mode . flycheck-mode))

    :config
    (setq merlin-completion-with-doc t))

  (use-package flycheck-ocaml
    :ensure t
    :config
    (add-hook 'tuareg-mode-hook
              (lambda ()
		(setq-local merlin-error-after-save nil)
		(flycheck-ocaml-setup))))
  
  (use-package ocamlformat
    :config
    (define-key tuareg-mode-map (kbd "C-x x f") 'ocamlformat-before-save)))

;; C/C++
(setq-default c-offsets-alist
	      '((defun-open . 2)
		(defun-close . 0)
		(class-open . 2)
		(class-close . 2)
		(access-label . -1)))

;; Proof Environment for Coq
(use-package proof-general
  :defer t
  :init
  (use-package company-coq
    :defer t
    :hook (coq-mode . company-coq)))

;; window numbering
(use-package window-numbering
  :defer t
  :hook (after-init . window-numbering-mode))

;; Markdown
(use-package markdown-mode
  :defer t
  :hook (markdown-mode . darkroom-mode))

(use-package darkroom
  :defer t
  :config
  (setq darkroom-margin-increment 0.1)

  :init
  (setq auto-mode-alist (append '(("README" . darkroom-mode)) auto-mode-alist)))

;; Goto line preview
(use-package goto-line-preview
  :defer t
  :init
  (global-set-key [remap goto-line] 'goto-line-preview))

;; Translate
(use-package youdao-dictionary
  :defer t
  :init
  (global-set-key (kbd "C-c y") 'youdao-dictionary-search-at-point-posframe)
  (global-set-key (kbd "C-c p") 'youdao-dictionary-play-voice-at-point))

;; Which key
(use-package which-key
  :defer t
  :init
  (which-key-mode t))

(provide 'init)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; init.el ends here

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
