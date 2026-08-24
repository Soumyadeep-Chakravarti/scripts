#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/packages.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
action_parse_flags "$@"
((${#ACTION_ARGS[@]} == 0)) || die 'Usage: x11.sh [--dry-run] [--yes]'
require_native_desktop
case "$(detect_package_manager)" in
    pacman) packages_install xorg-server xorg-xinit ;;
    apt) packages_install xorg xinit ;;
esac
