#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/menu.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
require_interactive
while true; do
    if ! menu_choose 'Projects' 'Clone one GitHub repository' 'Clone all GitHub repositories' 'Show project directory'; then
        log_warn 'Select a valid menu option.'
        continue
    fi
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1)
            bash "$SCRIPT_ROOT/projects/clone-project.sh"
            pause
            ;;
        2)
            bash "$SCRIPT_ROOT/projects/clone-all.sh"
            pause
            ;;
        3)
            ls -la "$HOME/projects" 2> /dev/null || log_info "No project directory at $HOME/projects"
            pause
            ;;
    esac
done
