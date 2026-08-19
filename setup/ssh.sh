#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

SSH_DIR="$HOME/.ssh"
CONFIG="$SSH_DIR/config"
AUTOMATION_KEY="$SSH_DIR/github-automation"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ ! -f "$AUTOMATION_KEY" ]]; then
    die "github-automation identity does not exist. Run security/keys/generate.sh first."
fi

touch "$CONFIG"
chmod 600 "$CONFIG"

if grep -qE '^Host[[:space:]]+github-automation$' "$CONFIG"; then
    log_info "github-automation SSH host already configured."
    exit 0
fi
