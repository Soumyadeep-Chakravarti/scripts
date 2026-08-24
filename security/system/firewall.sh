#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/packages.sh"

install=0
for arg in "$@"; do
    case "$arg" in
        --install) install=1 ;;
        *) parse_common_flag "$arg" || die "Usage: firewall.sh [--dry-run] [--yes] [--install]" ;;
    esac
done

status_firewall() {
    if command_exists ufw; then
        sudo ufw status verbose
    elif command_exists firewall-cmd; then
        sudo firewall-cmd --state
        sudo firewall-cmd --list-all
    else
        log_warn "No supported firewall frontend detected."
    fi
}

status_firewall

if ((!install)); then
    log_info "This is a status-only preview. Re-run with --install to install and enable a firewall service."
    log_info "No allow/deny rules are changed; review remote access before managing rules yourself."
    exit 0
fi

if command_exists ufw || command_exists firewall-cmd; then
    log_info "A supported firewall frontend is already installed; no service state was changed."
    exit 0
fi

case "$(detect_package_manager)" in
    pacman)
        package=ufw
        service=ufw.service
        ;;
    apt)
        package=ufw
        service=ufw.service
        ;;
    *) die "Firewall installation is not supported by the detected package manager." ;;
esac

log_warn "Installing/enabling a firewall can affect network access. No rules will be imposed by this script."
packages_install "$package" || exit 0
run_mutating "Enable firewall service $service" sudo systemctl enable --now "$service" || exit 0
status_firewall
