#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/packages.sh"
source "$SCRIPT_ROOT/lib/actions.sh"

action_parse_flags "$@"
action="${ACTION_ARGS[0]:-status}"
((${#ACTION_ARGS[@]} <= 1)) || die 'Usage: tailscale.sh [--dry-run] [--yes] {status|install|start|enable}'
case "$action" in
    status)
        service_command
        systemctl status tailscaled.service --no-pager
        ;;
    install) packages_install tailscale ;;
    start)
        service_command
        run_mutating 'Start Tailscale service' sudo systemctl start tailscaled.service
        ;;
    enable)
        service_command
        run_mutating 'Enable Tailscale service' sudo systemctl enable tailscaled.service
        ;;
    *) die 'Usage: tailscale.sh [--dry-run] [--yes] {status|install|start|enable}' ;;
esac
