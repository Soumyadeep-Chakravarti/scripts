#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/actions.sh"

action_parse_flags "$@"
destination="${ACTION_ARGS[0]:-$HOME/projects}"
((${#ACTION_ARGS[@]} <= 1)) || die 'Usage: clone-all.sh [--dry-run] [--yes] [destination]'
require_command gh
gh auth status > /dev/null 2>&1 || die 'GitHub CLI is not authenticated.'
mapfile -t repositories < <(gh repo list "$(gh api user --jq .login)" --limit 1000 --json nameWithOwner,isArchived --jq '.[] | select(.isArchived == false) | .nameWithOwner')
((${#repositories[@]})) || {
    log_warn 'No non-archived repositories found.'
    exit 0
}
if [[ ! -d "$destination" ]]; then
    run_mutating "Create project directory $destination" mkdir -p "$destination" || exit 0
fi
for repo in "${repositories[@]}"; do
    target="$destination/${repo#*/}"
    if [[ -e "$target" || -L "$target" ]]; then
        log_warn "Skipped existing path: $target"
        continue
    fi
    run_mutating "Clone $repo into $target" gh repo clone "$repo" "$target" || log_warn "Skipped or failed: $repo"
done
