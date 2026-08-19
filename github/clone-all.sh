#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_command gh

if ! gh auth status >/dev/null 2>&1; then
    die "GitHub CLI is not authenticated. Run setup/github.sh first."
fi

read -r -p "Clone destination [${HOME}/projects]: " DEST
DEST="${DEST:-$HOME/projects}"

mkdir -p "$DEST"

log_info "Fetching repository list..."

mapfile -t REPOS < <(
    gh repo list "$(
        gh api user --jq '.login'
    )" \
        --limit 1000 \
        --json nameWithOwner,isArchived \
        --jq '.[] | select(.isArchived == false) | .nameWithOwner'
)

if ((${#REPOS[@]} == 0)); then
    log_warn "No repositories found."
    exit 0
fi

printf '\n'
log_info "Found ${#REPOS[@]} repositories."
printf '\n'

FAILED=()

for REPO in "${REPOS[@]}"; do
    NAME="${REPO#*/}"
    TARGET="$DEST/$NAME"

    if [[ -d "$TARGET/.git" ]]; then
        log_info "Already exists: $REPO"
        continue
    fi

    printf '%b==>%b %s\n' "$CYAN" "$RESET" "$REPO"

    if gh repo clone "$REPO" "$TARGET"; then
        log_success "Cloned $REPO"
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

log_success "All repositories cloned successfully."
