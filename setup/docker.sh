#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/packages.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
action_parse_flags "$@"
((${#ACTION_ARGS[@]} == 0)) || die "Unknown option: ${ACTION_ARGS[0]}"
case "$(detect_package_manager)" in
    pacman) packages_install docker docker-compose ;;
    apt) packages_install docker.io docker-compose-plugin ;;
esac
log_info 'Docker is installed only. Use Services to explicitly enable or start it.'
