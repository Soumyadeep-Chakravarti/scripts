#!/usr/bin/env bash

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/menu.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
require_interactive
while true; do
    menu_choose 'Desktop' 'Install TTY tools' 'Install X11 base' 'Install Wayland base' 'Install i3' 'Install KDE Plasma' || continue
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1)
            bash "$SCRIPT_ROOT/desktop/tty.sh"
            pause
            ;;
        2)
            bash "$SCRIPT_ROOT/desktop/x11.sh"
            pause
            ;;
        3)
            bash "$SCRIPT_ROOT/desktop/wayland.sh"
            pause
            ;;
        4)
            bash "$SCRIPT_ROOT/desktop/i3.sh"
            pause
            ;;
        5)
            bash "$SCRIPT_ROOT/desktop/plasma.sh"
            pause
            ;;
    esac
done
