#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/packages.sh"

install_keyring() {
    if command_exists secret-tool; then
        log_success "Secret Service tooling already installed."
        return 0
    fi

    log_info "Installing Secret Service tooling..."

    case "$PKG_MANAGER" in
        pacman)
            install_packages libsecret
            ;;
        apt)
            install_packages libsecret-tools
            ;;
        dnf)
            install_packages libsecret
            ;;
        zypper)
            install_packages libsecret
            ;;
        *)
            die "Keyring installation is not yet supported for: $PKG_MANAGER"
            ;;
    esac

    log_success "Keyring tooling installed."
}

keyring_status() {
    printf '%bKeyring status%b\n\n' "$BOLD" "$RESET"

    if command_exists secret-tool; then
        log_success "secret-tool available."
    else
        log_warn "secret-tool not installed."
    fi

    if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
        log_success "D-Bus session detected."
    else
        log_warn "No D-Bus session detected."
        log_info "This is normal on many pure TTY/WSL environments."
    fi
}

store_secret() {
    require_command secret-tool

    local service="$1"
    local account="$2"

    printf 'Enter secret for %s/%s: ' "$service" "$account"
    read -rs SECRET
    printf '\n'

    printf '%s' "$SECRET" |
        secret-tool store \
            --label="$service/$account" \
            service "$service" \
            account "$account"

    unset SECRET

    log_success "Secret stored in the system keyring."
}

lookup_secret() {
    require_command secret-tool

    local service="$1"
    local account="$2"

    secret-tool lookup \
        service "$service" \
        account "$account"
}

delete_secret() {
    require_command secret-tool

    local service="$1"
    local account="$2"

    secret-tool clear \
        service "$service" \
        account "$account"

    log_success "Secret removed from keyring."
}

menu() {
    while true; do
        clear 2>/dev/null || true

        print_banner

        cat <<'MENU'
Keyring

  1) Install / verify keyring
  2) Show keyring status
  3) Store secret
  4) Retrieve secret
  5) Delete secret
  0) Back

MENU

        read -r -p "Select: " CHOICE

        case "$CHOICE" in
            1)
                install_keyring
                pause
                ;;

            2)
                keyring_status
                pause
                ;;

            3)
                read -r -p "Service: " SERVICE
                read -r -p "Account/name: " ACCOUNT
                store_secret "$SERVICE" "$ACCOUNT"
                pause
                ;;

            4)
                read -r -p "Service: " SERVICE
                read -r -p "Account/name: " ACCOUNT
                printf '\n'
                lookup_secret "$SERVICE" "$ACCOUNT"
                printf '\n'
                pause
                ;;

            5)
                read -r -p "Service: " SERVICE
                read -r -p "Account/name: " ACCOUNT

                if confirm "Delete $SERVICE/$ACCOUNT?"; then
                    delete_secret "$SERVICE" "$ACCOUNT"
                fi

                pause
                ;;

            0)
                exit 0
                ;;

            *)
                log_warn "Invalid selection."
                sleep 1
                ;;
        esac
    done
}

menu
