#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

if ! command_exists gh; then
    log_error "GitHub CLI (gh) is not installed."
    log_info "Install GitHub CLI first, then run this again."
    exit 1
fi

if gh auth status > /dev/null 2>&1; then
    log_success "GitHub CLI is already authenticated."
    gh auth status
    exit 0
fi

log_info "Starting GitHub authentication..."

gh auth login --git-protocol ssh

log_success "GitHub authentication complete."
gh auth status
