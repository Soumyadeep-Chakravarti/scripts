#!/usr/bin/env bash

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/menu.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
require_interactive
while true; do
    menu_choose 'Development' 'Set up system baseline' 'Install base tools' 'Install language runtimes' 'Install Neovim' 'Install Zsh and Starship' 'Install Nix' 'Deploy dotfiles' 'Install keyring support' || continue
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1) bash "$SCRIPT_ROOT/setup/system.sh" ;;
        2) bash "$SCRIPT_ROOT/setup/base-tools.sh" ;;
        3) bash "$SCRIPT_ROOT/setup/runtimes.sh" ;;
        4) bash "$SCRIPT_ROOT/setup/neovim.sh" ;;
        5) bash "$SCRIPT_ROOT/setup/shell.sh" ;;
        6) bash "$SCRIPT_ROOT/setup/nix.sh" ;;
        7) bash "$SCRIPT_ROOT/setup/dotfiles.sh" ;;
        8) bash "$SCRIPT_ROOT/setup/keyring.sh" ;;
    esac
    pause
done
