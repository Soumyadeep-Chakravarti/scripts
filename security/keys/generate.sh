#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

SSH_DIR="$HOME/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

printf '%bSSH identity generator%b\n\n' "$BOLD" "$RESET"

read -r -p "Identity name [github-automation]: " NAME
NAME="${NAME:-github-automation}"

read -r -p "Comment [${NAME}@$(hostname)]: " COMMENT
COMMENT="${COMMENT:-${NAME}@${HOSTNAME:-localhost}}"

KEY="$SSH_DIR/$NAME"

if [[ -e "$KEY" || -e "$KEY.pub" ]]; then
    die "Identity already exists: $KEY"
fi

log_info "Generating Ed25519 identity..."
log_info "Purpose: $NAME"

ssh-keygen \
    -t ed25519 \
    -f "$KEY" \
    -C "$COMMENT"

chmod 600 "$KEY"
chmod 644 "$KEY.pub"

printf '\n'
log_success "Identity created."
printf '\n'

printf '%bPublic key:%b\n' "$BOLD" "$RESET"
cat "$KEY.pub"

printf '\n'
log_info "Private key: $KEY"
log_warn "Never commit the private key."
