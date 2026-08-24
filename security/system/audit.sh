#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

for arg in "$@"; do
    parse_common_flag "$arg" || die "Usage: audit.sh [--dry-run] [--yes]"
done
[[ "$DRY_RUN" == 1 ]] && log_info '--dry-run has no effect: audit is read-only.'

printf '%bSystem security audit%b\n\n' "$BOLD" "$RESET"

checks=(
    "SSH:$(command -v sshd 2> /dev/null || true)"
    "Firewall:$(command -v ufw 2> /dev/null || command -v firewall-cmd 2> /dev/null || true)"
    "Sudo:$(command -v sudo 2> /dev/null || true)"
    "Git:$(command -v git 2> /dev/null || true)"
)

for check in "${checks[@]}"; do
    name="${check%%:*}"
    value="${check#*:}"

    if [[ -n "$value" ]]; then
        log_success "$name: $value"
    else
        log_warn "$name: not detected"
    fi
done

printf '\n%bSSH configuration%b\n' "$BOLD" "$RESET"

if [[ -f /etc/ssh/sshd_config ]]; then
    log_success "/etc/ssh/sshd_config exists."

    grep -E \
        '^[[:space:]]*(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|PermitEmptyPasswords)' \
        /etc/ssh/sshd_config \
        2> /dev/null || true
else
    log_info "No SSH daemon configuration detected."
fi
