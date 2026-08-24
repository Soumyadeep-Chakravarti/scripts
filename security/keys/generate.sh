#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

SSH_DIR="$HOME/.ssh"

for arg in "$@"; do
    parse_common_flag "$arg" || die "Usage: generate.sh [--dry-run] [--yes]"
done

printf '%bSSH identity generator%b\n\n' "$BOLD" "$RESET"

read -r -p "Identity name [github-automation]: " NAME
NAME="${NAME:-github-automation}"

[[ "$NAME" == "$(basename -- "$NAME")" && "$NAME" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] ||
    die "Identity name must be a safe basename (letters, digits, dot, underscore, and hyphen only)."

read -r -p "Comment [${NAME}@${HOSTNAME:-localhost}]: " COMMENT
COMMENT="${COMMENT:-${NAME}@${HOSTNAME:-localhost}}"

KEY="$SSH_DIR/$NAME"

if [[ -e "$KEY" || -e "$KEY.pub" ]]; then
    die "Identity already exists: $KEY"
fi

run_mutating "Generate Ed25519 identity $NAME" bash -c '
    set -euo pipefail
    umask 077
    mkdir -p "$1"
    chmod 700 "$1"
    ssh-keygen -t ed25519 -f "$2" -C "$3"
    chmod 600 "$2"
    chmod 644 "$2.pub"
' _ "$SSH_DIR" "$KEY" "$COMMENT" || exit 0

if [[ "$DRY_RUN" == 1 ]]; then
    log_info "Identity generation preview complete."
    exit 0
fi

printf '\n'
log_success "Identity created."
printf '\n'

printf '%bPublic key:%b\n' "$BOLD" "$RESET"
[[ "$DRY_RUN" == 1 ]] || cat "$KEY.pub"

printf '\n'
log_info "Private key: $KEY"
log_warn "Never commit the private key."
