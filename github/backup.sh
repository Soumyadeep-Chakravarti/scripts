#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_command gh
require_command jq

if ! gh auth status >/dev/null 2>&1; then
    die "GitHub CLI is not authenticated."
fi

read -r -p "Backup directory [${HOME}/github-backup]: " DEST
DEST="${DEST:-$HOME/github-backup}"

mkdir -p "$DEST"

USERNAME="$(gh api user --jq '.login')"

log_info "Backing up GitHub metadata for $USERNAME..."

gh api user > "$DEST/user.json"

gh repo list "$USERNAME" \
    --limit 1000 \
    --json name,nameWithOwner,description,isPrivate,isArchived,defaultBranchRef,url,sshUrl \
    > "$DEST/repositories.json"

gh ssh-key list > "$DEST/ssh-keys.txt" || true

gh gist list > "$DEST/gists.txt" || true

log_success "GitHub metadata backup complete."
log_info "Stored in: $DEST"
