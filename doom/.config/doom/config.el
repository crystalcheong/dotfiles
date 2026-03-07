;;; config.el -*- lexical-binding: t; -*-

(setq user-full-name "Crystal Cheong"
      user-mail-address "65748007+crystalcheong@users.noreply.github.com")

(setq doom-theme 'doom-one
      display-line-numbers-type 'relative
      org-directory "~/org/")

;; Terminal/tmux-friendly behavior.
(setq select-enable-clipboard t
      x-select-enable-clipboard t)

;; Keep subprocess execution POSIX-safe while still using fish in terminals.
(setq shell-file-name (or (executable-find "bash") "/bin/sh")
      explicit-shell-file-name (or (executable-find "fish") shell-file-name))
(after! vterm
  (setq vterm-shell (or (executable-find "fish") shell-file-name)))

(after! magit
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1))

(defun dev/devcontainer--workspace ()
  "Return workspace root for devcontainer commands."
  (or (locate-dominating-file default-directory ".devcontainer")
      (when (fboundp 'projectile-project-root)
        (ignore-errors (projectile-project-root)))
      default-directory))

(defun dev/devcontainer-up ()
  "Start/refresh the current workspace devcontainer."
  (interactive)
  (let ((root (expand-file-name (dev/devcontainer--workspace))))
    (compile (format "devcontainer up --workspace-folder %s"
                     (shell-quote-argument root)))))

(defun dev/devcontainer-exec (cmd)
  "Run CMD inside the current workspace devcontainer."
  (interactive "sdevcontainer exec command: ")
  (let ((root (expand-file-name (dev/devcontainer--workspace))))
    (compile (format "devcontainer exec --workspace-folder %s %s"
                     (shell-quote-argument root) cmd))))

(defun dev/devcontainer-shell ()
  "Open a shell inside the current workspace devcontainer."
  (interactive)
  (dev/devcontainer-exec "bash -lc '$SHELL -l || bash -l || sh -l'"))

(map! :leader
      :desc "devcontainer up" "o u" #'dev/devcontainer-up
      :desc "devcontainer exec" "o e" #'dev/devcontainer-exec
      :desc "devcontainer shell" "o s" #'dev/devcontainer-shell)
