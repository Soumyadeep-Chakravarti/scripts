#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_command git

root=""
for arg in "$@"; do
    if parse_common_flag "$arg"; then
        continue
    fi
    [[ -z "$root" ]] || die "Usage: sync-all.sh [--dry-run] [--yes] [projects-directory]"
    root="$arg"
done
if [[ -z "$root" ]]; then
    read -r -p "Projects directory [${HOME}/projects]: " root
fi
ROOT="${root:-$HOME/projects}"

[[ -d "$ROOT" ]] || die "Directory does not exist: $ROOT"

FAILED=()
SKIPPED=()
UPDATED=()

while IFS= read -r -d '' GITDIR; do
    REPO="${GITDIR%/.git}"

    printf '\n%b==>%b %s\n' "$CYAN" "$RESET" "$REPO"

    if ! git -C "$REPO" status --porcelain > /dev/null 2>&1; then
        log_warn "Unable to inspect repository — skipped."
        SKIPPED+=("$REPO")
        continue
    fi

    if [[ -n "$(git -C "$REPO" status --porcelain)" ]]; then
        log_warn "Dirty working tree — skipped."
        SKIPPED+=("$REPO")
        continue
    fi

    if ! git -C "$REPO" remote get-url origin > /dev/null 2>&1; then
        log_warn "No origin remote — skipped."
        SKIPPED+=("$REPO")
        continue
    fi

    if [[ -f "$REPO/.gitattributes" ]] && grep -q 'filter=lfs' "$REPO/.gitattributes" && ! git lfs version > /dev/null 2>&1; then
        log_warn "Repository uses Git LFS but git-lfs is unavailable — skipped."
        SKIPPED+=("$REPO")
        continue
    fi

    if run_mutating "Fetch updates for $REPO" git -C "$REPO" fetch --prune origin &&
        run_mutating "Fast-forward $REPO" git -C "$REPO" pull --ff-only; then
        UPDATED+=("$REPO")
        [[ "$DRY_RUN" == 1 ]] && log_info "Planned sync." || log_success "Synced."
    else
        log_error "Sync failed."
        FAILED+=("$REPO")
    fi

done < <(
    find "$ROOT" \
        -mindepth 2 \
        -maxdepth 2 \
        -type d \
        -name .git \
        -print0
)

printf '\n'
printf '%b========== SUMMARY ==========%b\n' "$BOLD" "$RESET"

printf 'Updated: %d\n' "${#UPDATED[@]}"
printf 'Skipped: %d\n' "${#SKIPPED[@]}"
printf 'Failed:  %d\n' "${#FAILED[@]}"

if ((${#SKIPPED[@]})); then
    printf '\n%bSkipped:%b\n' "$YELLOW" "$RESET"
    printf '  %s\n' "${SKIPPED[@]}"
fi

if ((${#FAILED[@]})); then
    printf '\n%bFailed:%b\n' "$RED" "$RESET"
    printf '  %s\n' "${FAILED[@]}"
    exit 1
fi

[[ "$DRY_RUN" == 1 ]] && log_info "Repository sync preview complete." || log_success "Repository sync complete."
