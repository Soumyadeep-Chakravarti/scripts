#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

log_info "Checking sensitive local permissions..."

check_mode() {
    local path="$1"
    local expected="$2"

    [[ -e "$path" ]] || return 0

    local mode
    mode="$(stat -c '%a' "$path" 2>/dev/null || stat -f '%Lp' "$path" 2>/dev/null || true)"

    if [[ "$mode" == "$expected" ]]; then
        log_success "$path: $mode"
    else
        log_warn "$path: $mode (expected $expected)"
    fi
}

check_mode "$HOME/.ssh" 700
check_mode "$HOME/.ssh/config" 600

while IFS= read -r -d '' key; do
    check_mode "$key" 600
done < <(
    find "$HOME/.ssh" \
        -maxdepth 1 \
        -type f \
        ! -name '*.pub' \
        -print0 2>/dev/null
)

log_success "Permission audit complete."
