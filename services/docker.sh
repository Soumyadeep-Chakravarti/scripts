#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/actions.sh"

action_parse_flags "$@"
action="${ACTION_ARGS[0]:-status}"
((${#ACTION_ARGS[@]} <= 1)) || die 'Usage: docker.sh [--dry-run] [--yes] {status|install|start|enable}'
case "$action" in
    status)
        service_command
        systemctl status docker.service --no-pager
        ;;
    install) DRY_RUN="$DRY_RUN" ASSUME_YES="$ASSUME_YES" bash "$SCRIPT_ROOT/setup/docker.sh" ;;
    start)
        service_command
        run_mutating 'Start Docker service' sudo systemctl start docker.service
        ;;
    enable)
        service_command
        run_mutating 'Enable Docker service' sudo systemctl enable docker.service
        ;;
    *) die 'Usage: docker.sh [--dry-run] [--yes] {status|install|start|enable}' ;;
esac
