#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
action_parse_flags "$@"
((${#ACTION_ARGS[@]} == 0)) || die 'Usage: cleanup.sh [--dry-run] [--yes]'
case "$(detect_package_manager)" in
    pacman)
        mapfile -t orphans < <(pacman -Qtdq 2> /dev/null || true)
        ((${#orphans[@]})) || {
            log_info 'No unused pacman packages found.'
            exit 0
        }
        run_mutating 'Remove unused pacman packages' sudo pacman -Rns -- "${orphans[@]}"
        ;;
    apt)
        command=(sudo apt-get autoremove)
        [[ "$ASSUME_YES" == 1 ]] && command+=(-y)
        run_mutating 'Remove unused apt packages' "${command[@]}"
        ;;
esac
