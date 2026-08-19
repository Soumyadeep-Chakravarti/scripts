#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/packages.sh"

install_firewall() {
    case "$PKG_MANAGER" in
        pacman)
            install_packages ufw
            ;;
        apt)
            install_packages ufw
            ;;
        dnf)
            install_packages firewalld
            ;;
        *)
            die "Firewall setup is not mapped for $PKG_MANAGER"
            ;;
    esac
}

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

install_firewall
status_firewall
