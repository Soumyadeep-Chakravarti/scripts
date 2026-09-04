#!/usr/bin/env bash

set -o pipefail

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/profile.sh"
source "$SCRIPT_ROOT/lib/menu.sh"

usage() {
    printf 'Usage: %s [--profile wsl-arch|arch|ubuntu-dev] [--dry-run] [--yes]\n' "${0##*/}"
}

profile=''
while (($#)); do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || die '--profile requires a value.'
            profile="$2"
            shift 2
            ;;
        --help | -h)
            usage
            exit 0
            ;;
        *)
            if parse_common_flag "$1"; then
                shift
            else
                die "Unknown option: $1"
            fi
            ;;
    esac
done

if [[ -z "$profile" ]]; then
    profile=$(profile_default) || die 'Cannot select a profile automatically; pass --profile.'
fi
profile_load "$profile" || exit 1
profile_verify_environment || exit 1
[[ -t 0 ]] || die 'An interactive terminal is required for bootstrap menus.'
export DRY_RUN ASSUME_YES

while true; do
    if ! menu_choose "Bootstrap: $PROFILE_DESCRIPTION" \
        'Development' 'Desktop' 'GitHub' 'Maintenance' 'Projects' 'Security' 'System'; then
        log_warn 'Select a valid menu option.'
        continue
    fi
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1) bash "$SCRIPT_ROOT/menu/development.sh" ;;
        2) bash "$SCRIPT_ROOT/menu/desktop.sh" ;;
        3) bash "$SCRIPT_ROOT/menu/github.sh" ;;
        4) bash "$SCRIPT_ROOT/menu/maintenance.sh" ;;
        5) bash "$SCRIPT_ROOT/menu/projects.sh" ;;
        6) bash "$SCRIPT_ROOT/menu/security.sh" ;;
        7) bash "$SCRIPT_ROOT/menu/system.sh" ;;
    esac
done
