#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_command gh
require_command git

for arg in "$@"; do
    parse_common_flag "$arg" || die "Usage: backup.sh [--dry-run] [--yes]"
done

if ! gh auth status > /dev/null 2>&1; then
    die "GitHub CLI is not authenticated."
fi

read -r -p "Backup directory [${HOME}/github-backup]: " DEST
DEST="${DEST:-$HOME/github-backup}"

USERNAME="$(gh api user --jq '.login')"
timestamp="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$DEST/${USERNAME}-${timestamp}"
[[ ! -e "$BACKUP_DIR" ]] || die "Backup destination already exists: $BACKUP_DIR"

log_info "Backing up GitHub metadata for $USERNAME..."

run_mutating "Back up GitHub metadata to $BACKUP_DIR" bash -c '
    set -euo pipefail
    destination=$1 username=$2
    umask 077
    mkdir -p "$destination"
    chmod 700 "$destination"
    gh api user > "$destination/user.json"
    gh repo list "$username" --limit 1000 \
        --json name,nameWithOwner,description,isPrivate,isArchived,defaultBranchRef,url,sshUrl \
        > "$destination/repositories.json"
    gh ssh-key list > "$destination/ssh-keys.txt" || true
    gh gist list > "$destination/gists.txt" || true
    chmod 600 "$destination"/*
' _ "$BACKUP_DIR" "$USERNAME" || exit 0

if [[ "$DRY_RUN" == 1 ]]; then
    log_info "GitHub metadata backup preview complete."
else
    log_success "GitHub metadata backup complete."
    log_info "Stored in: $BACKUP_DIR (directory mode 700; metadata mode 600)."
fi
