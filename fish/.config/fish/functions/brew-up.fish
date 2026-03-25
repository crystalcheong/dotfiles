function brew-up --description "Update and maintain Homebrew + dotfiles brewfile"
    if not type -q brew
        echo "brew not found."
        return 1
    end

    set -l dotfiles_dir "$HOME/dotfiles"
    set -l brewfile "$dotfiles_dir/brewfile"
    if not test -f $brewfile
        echo "brewfile not found at $brewfile"
        return 1
    end

    echo "==> brew update"
    brew update

    echo "==> brew outdated (quick status)"
    set -l outdated (brew outdated)
    set -l outdated_count (count $outdated)
    if test $outdated_count -eq 0
        echo "No outdated packages."
    else
        echo "$outdated_count outdated package(s):"
        printf '%s\n' $outdated
    end

    echo "==> brew upgrade"
    brew upgrade

    echo "==> brew bundle install --upgrade"
    brew bundle install --file $brewfile --upgrade

    echo "==> brew autoremove"
    brew autoremove

    echo "==> brew cleanup --prune=all"
    brew cleanup --prune=all

    echo "Homebrew maintenance complete."
end
