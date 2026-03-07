;;; init.el -*- lexical-binding: t; -*-

(doom! :input

       :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       (vc-gutter +pretty)
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets
       (whitespace +guess +trim)

       :emacs
       dired
       electric
       tramp
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       direnv
       docker
       editorconfig
       (eval +overlay)
       lookup
       (lsp +eglot)
       magit
       make
       tree-sitter

       :os
       (:if (featurep :system 'macos) macos)
       tty

       :lang
       emacs-lisp
       json
       (javascript +lsp +tree-sitter)
       markdown
       org
       (python +lsp)
       sh
       (web +lsp)
       yaml

       :config
       (default +bindings +smartparens))
