#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

SSH_DIR="$HOME/.ssh"

for arg in "$@"; do
    parse_common_flag "$arg" || die "Usage: list.sh [--dry-run] [--yes]"
done
[[ "$DRY_RUN" == 1 ]] && log_info '--dry-run has no effect: listing keys is read-only.'

printf '%bManaged SSH keys%b\n\n' "$BOLD" "$RESET"

found=0

while IFS= read -r -d '' PUB; do
    found=1

    KEY="${PUB%.pub}"

    printf '%b%s%b\n' "$CYAN" "$(basename "$KEY")" "$RESET"

    if command_exists ssh-keygen; then
        ssh-keygen -lf "$PUB" 2> /dev/null || true
    fi

    printf '  Public:  %s\n' "$PUB"
    printf '  Private: %s\n\n' "$KEY"

done < <(
    find "$SSH_DIR" \
        -maxdepth 1 \
        -type f \
        -name '*.pub' \
        -print0
)

if ((!found)); then
    log_info "No SSH public keys found."
fi
