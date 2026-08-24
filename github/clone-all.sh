#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_command gh
require_command git

destination=""
for arg in "$@"; do
    if parse_common_flag "$arg"; then
        continue
    fi
    [[ -z "$destination" ]] || die "Usage: clone-all.sh [--dry-run] [--yes] [destination]"
    destination="$arg"
done

if ! gh auth status > /dev/null 2>&1; then
    die "GitHub CLI is not authenticated. Run setup/github.sh first."
fi

if [[ -z "$destination" ]]; then
    read -r -p "Clone destination [${HOME}/projects]: " destination
fi
DEST="${destination:-$HOME/projects}"

log_info "Fetching repository list..."

USERNAME="$(gh api user --jq '.login')" || die "Unable to determine the authenticated GitHub user."
if ! repo_output="$(gh repo list "$USERNAME" --limit 1000 --json nameWithOwner,isArchived --jq '.[] | select(.isArchived == false) | .nameWithOwner')"; then
    die "Unable to fetch repositories from GitHub."
fi
if [[ -z "$repo_output" ]]; then
    REPOS=()
else
    mapfile -t REPOS <<< "$repo_output"
fi

if ((${#REPOS[@]} == 0)); then
    log_warn "No repositories found."
    exit 0
fi

printf '\n'
log_info "Found ${#REPOS[@]} repositories."
printf '\n'

FAILED=()

if [[ ! -d "$DEST" ]]; then
    run_mutating "Create clone destination $DEST" mkdir -p -- "$DEST" || exit 0
fi

for REPO in "${REPOS[@]}"; do
    NAME="${REPO#*/}"
    TARGET="$DEST/$NAME"

    if [[ -e "$TARGET" || -L "$TARGET" ]]; then
        log_warn "Skipped existing path (collision): $TARGET"
        continue
    fi

    printf '%b==>%b %s\n' "$CYAN" "$RESET" "$REPO"

    if run_mutating "Clone $REPO into $TARGET" gh repo clone "$REPO" "$TARGET"; then
        [[ "$DRY_RUN" == 1 ]] && log_info "Planned clone: $REPO" || log_success "Cloned $REPO"
    else
        log_error "Failed to clone $REPO"
        FAILED+=("$REPO")
    fi
done

printf '\n'

if ((${#FAILED[@]} > 0)); then
    log_warn "${#FAILED[@]} repositories failed:"
    printf '  %s\n' "${FAILED[@]}"
    exit 1
fi

[[ "$DRY_RUN" == 1 ]] && log_info "Repository clone preview complete." || log_success "All repositories cloned successfully."
