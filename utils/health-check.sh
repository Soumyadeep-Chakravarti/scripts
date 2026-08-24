#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/packages.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
action_parse_flags "$@"
((${#ACTION_ARGS[@]} == 0)) || die 'Usage: health-check.sh [--dry-run] [--yes]'
[[ "$DRY_RUN" == 1 ]] && log_info '--dry-run has no effect: health check is read-only.'
for command in git curl zsh nvim; do
    if command_exists "$command"; then log_success "$command is available."; else log_warn "$command is missing."; fi
done
if command_exists systemctl; then
    systemctl is-system-running --wait 2> /dev/null || log_warn 'systemd is not fully running.'
fi
