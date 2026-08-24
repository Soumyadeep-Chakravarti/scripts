#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

name=""
for arg in "$@"; do
    if parse_common_flag "$arg"; then
        continue
    fi
    [[ -z "$name" ]] || die "Usage: remove.sh [--dry-run] [--yes] [identity-name]"
    name="$arg"
done

if [[ -z "$name" ]]; then
    read -r -p "Exact identity name to remove: " name
fi
[[ "$name" == "$(basename -- "$name")" && "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "Identity name must be a safe basename."

key="$HOME/.ssh/$name"
public_key="$key.pub"
[[ -f "$public_key" ]] || die "Refusing to remove $name: no matching public identity exists."
[[ -f "$key" ]] || die "Refusing to remove $name: no matching private identity exists."

if command_exists ssh-keygen; then
    ssh-keygen -lf "$public_key" > /dev/null 2>&1 || die "Refusing to remove an invalid public key: $public_key"
fi

run_mutating "Remove exact SSH identity $name" rm -f -- "$key" "$public_key" || exit 0
if [[ "$DRY_RUN" == 1 ]]; then
    log_info "Identity removal preview complete."
else
    log_success "Removed SSH identity: $name"
fi
