#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
DOTFILES_ROOT=$(cd -- "$SCRIPT_ROOT/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/actions.sh"

action_parse_flags "$@"
((${#ACTION_ARGS[@]} == 0)) || die "Unknown option: ${ACTION_ARGS[0]}"

deploy_link() {
    local source_path="$1" destination="$2"

    if [[ -e "$destination" || -L "$destination" ]]; then
        log_warn "Skipped existing path: $destination"
        return 0
    fi
    if [[ ! -d "${destination%/*}" ]]; then
        run_mutating "Create ${destination%/*}" mkdir -p "${destination%/*}" || return
    fi
    run_mutating "Link $destination to repository asset" ln -s "$source_path" "$destination"
}

deploy_link "$DOTFILES_ROOT/zsh" "$HOME/.config/zsh"
deploy_link "$DOTFILES_ROOT/nvim" "$HOME/.config/nvim"
deploy_link "$DOTFILES_ROOT/starship.toml" "$HOME/.config/starship.toml"
deploy_link "$DOTFILES_ROOT/nix" "$HOME/.config/nix"
