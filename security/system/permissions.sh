#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

fix=0
for arg in "$@"; do
    case "$arg" in
        --fix) fix=1 ;;
        *) parse_common_flag "$arg" || die "Usage: permissions.sh [--dry-run] [--yes] [--fix]" ;;
    esac
done

log_info "Checking sensitive local permissions..."

check_mode() {
    local path="$1"
    local expected="$2"

    [[ -e "$path" ]] || return 0

    local mode
    mode="$(stat -c '%a' "$path" 2> /dev/null || stat -f '%Lp' "$path" 2> /dev/null || true)"

    if [[ "$mode" == "$expected" ]]; then
        log_success "$path: $mode"
    else
        log_warn "$path: $mode (expected $expected)"
        needs_fix+=("$path:$expected")
    fi
}

needs_fix=()

check_mode "$HOME/.ssh" 700
check_mode "$HOME/.ssh/config" 600

while IFS= read -r -d '' key; do
    check_mode "$key" 600
done < <(
    find "$HOME/.ssh" \
        -maxdepth 1 \
        -type f \
        ! -name '*.pub' \
        -print0 2> /dev/null
)

if ((!fix)); then
    log_success "Permission audit complete (read-only). Use --fix to correct reported modes."
    exit 0
fi

if ((${#needs_fix[@]} == 0)); then
    log_success "Permission audit complete; no fixes needed."
    exit 0
fi

for entry in "${needs_fix[@]}"; do
    path="${entry%:*}"
    mode="${entry##*:}"
    run_mutating "Set mode $mode on $path" chmod "$mode" -- "$path" || true
done
log_success "Permission fix pass complete."
