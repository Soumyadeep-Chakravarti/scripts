#!/usr/bin/env bash

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/menu.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
require_interactive
while true; do
    menu_choose 'Maintenance' 'Run health check' 'Remove unused packages' || continue
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1)
            bash "$SCRIPT_ROOT/utils/health-check.sh"
            pause
            ;;
        2)
            bash "$SCRIPT_ROOT/utils/cleanup.sh"
            pause
            ;;
    esac
done
