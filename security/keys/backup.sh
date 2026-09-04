#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

include_private=0
destination=''
for arg in "$@"; do
    case "$arg" in
        --include-private) include_private=1 ;;
        *)
            if parse_common_flag "$arg"; then
                continue
            fi
            [[ -z "$destination" ]] || die "Usage: backup.sh [--dry-run] [--yes] [--include-private] [destination]"
            destination="$arg"
            ;;
    esac
done

SSH_DIR="$HOME/.ssh"
if [[ -z "$destination" ]]; then
    [[ -t 0 ]] || die "A backup destination is required without an interactive terminal."
    read -r -p "Backup directory [${HOME}/ssh-key-backup]: " destination
fi
DEST="${destination:-$HOME/ssh-key-backup}"
timestamp="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$DEST/$timestamp"

if [[ -e "$BACKUP_DIR" ]]; then
    die "Backup destination already exists: $BACKUP_DIR"
fi

if ((include_private)) && [[ "$DRY_RUN" != 1 ]]; then
    log_warn "Private key material will be copied. This is normally unnecessary and high risk."
    [[ -t 0 ]] || die "Private-key backup requires an interactive terminal."
    read -r -p "Type BACKUP PRIVATE KEY to continue: " confirmation
    [[ "$confirmation" == "BACKUP PRIVATE KEY" ]] || die "Private-key backup cancelled."
fi

mapfile -t public_keys < <(compgen -G "$SSH_DIR/*.pub" || true)
((${#public_keys[@]})) || die "No public SSH keys found in $SSH_DIR"

run_mutating "Create SSH key backup at $BACKUP_DIR" bash -c '
    set -euo pipefail
    destination=$1 include_private=$2
    shift 2
    umask 077
    mkdir -p "$destination"
    chmod 700 "$destination"
    for public_key in "$@"; do
        name=$(basename -- "$public_key")
        cp -- "$public_key" "$destination/$name"
        chmod 644 "$destination/$name"
        if [[ "$include_private" == 1 && -f "${public_key%.pub}" ]]; then
            cp -- "${public_key%.pub}" "$destination/${name%.pub}"
            chmod 600 "$destination/${name%.pub}"
        fi
    done
' _ "$BACKUP_DIR" "$include_private" "${public_keys[@]}" || exit 0

if [[ "$DRY_RUN" == 1 ]]; then
    log_info "SSH key backup preview complete."
else
    log_success "SSH public keys backed up to: $BACKUP_DIR"
fi
