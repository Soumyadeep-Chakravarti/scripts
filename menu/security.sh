#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

while true; do
    clear 2>/dev/null || true
    print_banner

    cat <<'MENU'
Security

  1) System security
  2) Key & secret management
  0) Back

MENU

    read -r -p "Select: " CHOICE

    case "$CHOICE" in
        1)
            clear
            print_banner

            cat <<'SYSTEM'
System security

  1) Security audit
  2) Firewall
  3) SSH hardening
  4) Permission audit
  0) Back

SYSTEM

            read -r -p "Select: " SYSTEM_CHOICE

            case "$SYSTEM_CHOICE" in
                1) bash "$SCRIPT_DIR/security/system/audit.sh"; pause ;;
                2) bash "$SCRIPT_DIR/security/system/firewall.sh"; pause ;;
                3) bash "$SCRIPT_DIR/security/system/ssh-hardening.sh"; pause ;;
                4) bash "$SCRIPT_DIR/security/system/permissions.sh"; pause ;;
                0) ;;
                *) log_warn "Invalid selection."; sleep 1 ;;
            esac
            ;;

        2)
            clear
            print_banner

            cat <<'KEYS'
Key & secret management

  1) Keyring
  2) Generate SSH key
  3) List SSH keys
  4) Backup keys
  5) Remove key
  0) Back

KEYS

            read -r -p "Select: " KEY_CHOICE

            case "$KEY_CHOICE" in
                1) bash "$SCRIPT_DIR/security/keys/keyring.sh" ;;
                2) bash "$SCRIPT_DIR/security/keys/generate.sh"; pause ;;
                3) bash "$SCRIPT_DIR/security/keys/list.sh"; pause ;;
                4) bash "$SCRIPT_DIR/security/keys/backup.sh"; pause ;;
                5) bash "$SCRIPT_DIR/security/keys/remove.sh"; pause ;;
                0) ;;
                *) log_warn "Invalid selection."; sleep 1 ;;
            esac
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
