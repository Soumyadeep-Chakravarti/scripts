#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/detect.sh"

apply=0
for arg in "$@"; do
    case "$arg" in
        --apply) apply=1 ;;
        *) parse_common_flag "$arg" || die "Usage: ssh-hardening.sh [--dry-run] [--yes] [--apply]" ;;
    esac
done

if is_wsl; then
    log_info "SSH hardening is unsupported on WSL: no local SSH daemon is managed by this script."
    exit 0
fi

if ! command_exists sshd || [[ ! -f /etc/ssh/sshd_config ]]; then
    log_info "No local OpenSSH daemon/configuration was detected; nothing to harden."
    exit 0
fi

printf '%bSSH hardening audit%b\n' "$BOLD" "$RESET"
grep -E '^[[:space:]]*(PermitRootLogin|PasswordAuthentication|KbdInteractiveAuthentication|PermitEmptyPasswords)' /etc/ssh/sshd_config 2> /dev/null || true

if ! sudo sshd -t -f /etc/ssh/sshd_config; then
    die "Current sshd configuration fails validation; refusing to offer changes."
fi

if ((!apply)); then
    log_info "Preview only. Re-run with --apply to install an opt-in hardening drop-in."
    exit 0
fi

dropin=/etc/ssh/sshd_config.d/99-github-automation-hardening.conf
if sudo test -e "$dropin"; then
    die "Refusing to overwrite existing drop-in: $dropin"
fi

log_warn "The drop-in disables root and password authentication. Confirm console/key access before continuing."
timestamp="$(date +%Y%m%d-%H%M%S)"
run_mutating "Back up sshd_config and install SSH hardening drop-in" sudo bash -c '
    set -euo pipefail
    config=$1 dropin=$2 backup=$3
    mkdir -p "$(dirname "$dropin")"
    cp -p "$config" "$backup"
    chmod 600 "$backup"
    temp=$(mktemp)
    trap "rm -f \"$temp\"" EXIT
    cat > "$temp" <<"EOF"
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
EOF
    install -m 600 "$temp" "$dropin"
    sshd -t -f "$config"
' _ /etc/ssh/sshd_config "$dropin" "/etc/ssh/sshd_config.backup-$timestamp" || die "SSH hardening was not applied."
if [[ "$DRY_RUN" == 1 ]]; then
    log_info "SSH hardening preview complete."
else
    log_success "Hardening drop-in installed. Restart sshd manually after validating a second session."
fi
