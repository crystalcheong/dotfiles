if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux LANG en_US.UTF-8

# Override greeting prompt
set fish_greeting

# Homebrew
set -Ux PATH /opt/homebrew/bin $PATH

# SSH + GPG Agent
set -gx GPG_TTY (tty)
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Doom/Emacs CLI workflow
fish_add_path -m $HOME/.config/emacs/bin

if type -q zoxide
    zoxide init fish | source
end

function tree --description "Compact tree view (depth 2, hide dotfiles, respect .gitignore)"
    set -l path .
    if test (count $argv) -ge 1
        set path $argv[1]
    end
    eza --tree --level=2 --git-ignore --group-directories-first --icons=auto $path
end

function tree-all --description "Tree view including dotfiles (depth 2)"
    set -l path .
    if test (count $argv) -ge 1
        set path $argv[1]
    end
    eza --tree -a --level=2 --git-ignore --group-directories-first --icons=auto $path
end

function tree-depth --description "Tree view with custom depth: tree-depth <depth> [path]"
    set -l depth 2
    set -l path .

    if test (count $argv) -ge 1
        if string match -rq '^[0-9]+$' -- $argv[1]
            set depth $argv[1]
            if test (count $argv) -ge 2
                set path $argv[2]
            end
        else
            set path $argv[1]
        end
    end

    eza --tree --level=$depth --git-ignore --group-directories-first --icons=auto $path
end

function jump --description "Jump to a frequent directory: jump <query>"
    if test (count $argv) -ge 1
        z $argv
    else
        zi
    end
end

function jump-interactive --description "Interactive directory jump picker"
    zi
end

# Backwards-compatible short aliases
function ta --description "Alias for tree-all"
    tree-all $argv
end

function td --description "Alias for tree-depth"
    tree-depth $argv
end

function e --description "Open Emacs client in terminal (start daemon if needed)"
    if not pgrep -u (id -u) -x emacs >/dev/null
        emacs --daemon >/dev/null 2>&1
        sleep 0.2
    end
    emacsclient -t -a '' $argv
end

function ek --description "Stop Emacs daemon"
    emacsclient -e "(kill-emacs)"
end
