#!/usr/bin/env bash

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/menu.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
require_interactive
while true; do
    menu_choose 'Development' 'Install base tools' 'Install language runtimes' 'Install Neovim' 'Install Zsh and Starship' 'Install Nix' 'Deploy dotfiles' 'Install keyring support' || continue
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1)
            bash "$SCRIPT_ROOT/setup/base-tools.sh"
            pause
            ;;
        2)
            bash "$SCRIPT_ROOT/setup/runtimes.sh"
            pause
            ;;
        3)
            bash "$SCRIPT_ROOT/setup/neovim.sh"
            pause
            ;;
        4)
            bash "$SCRIPT_ROOT/setup/shell.sh"
            pause
            ;;
        5)
            bash "$SCRIPT_ROOT/setup/nix.sh"
            pause
            ;;
        6)
            bash "$SCRIPT_ROOT/setup/dotfiles.sh"
            pause
            ;;
        7)
            bash "$SCRIPT_ROOT/setup/keyring.sh"
            pause
            ;;
    esac
done
