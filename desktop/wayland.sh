#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/packages.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
action_parse_flags "$@"
((${#ACTION_ARGS[@]} == 0)) || die 'Usage: wayland.sh [--dry-run] [--yes]'
require_native_desktop
packages_install wayland wayland-protocols
