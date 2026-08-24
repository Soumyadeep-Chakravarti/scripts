#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/actions.sh"

action_parse_flags "$@"
repo="${ACTION_ARGS[0]:-}"
destination="${ACTION_ARGS[1]:-$HOME/projects}"
((${#ACTION_ARGS[@]} <= 2)) || die 'Usage: clone-project.sh [--dry-run] [--yes] [owner/repository] [destination]'
if [[ -z "$repo" ]]; then
    require_interactive
    read -r -p 'Repository (owner/repository): ' repo
fi
[[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die 'Repository must be in owner/repository form.'
require_command gh
gh auth status > /dev/null 2>&1 || die 'GitHub CLI is not authenticated.'
target="$destination/${repo#*/}"
[[ ! -e "$target" && ! -L "$target" ]] || die "Destination already exists: $target"
if [[ ! -d "$destination" ]]; then
    run_mutating "Create project directory $destination" mkdir -p "$destination" || exit 0
fi
run_mutating "Clone $repo into $target" gh repo clone "$repo" "$target"
