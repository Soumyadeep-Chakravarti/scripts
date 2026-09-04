#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/menu.sh"
source "$SCRIPT_ROOT/lib/actions.sh"

require_interactive

while true; do
    menu_choose 'Security' 'System security' 'Key and secret management' || continue
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1)
            while true; do
                menu_choose 'System security' 'Security audit' 'Firewall' 'SSH hardening' 'Permission audit' || continue
                case "$MENU_SELECTION" in
                    0) break ;;
                    1) bash "$SCRIPT_ROOT/security/system/audit.sh" ;;
                    2) bash "$SCRIPT_ROOT/security/system/firewall.sh" ;;
                    3) bash "$SCRIPT_ROOT/security/system/ssh-hardening.sh" ;;
                    4) bash "$SCRIPT_ROOT/security/system/permissions.sh" ;;
                esac
                pause
            done
            ;;
        2)
            while true; do
                menu_choose 'Key and secret management' 'Keyring' 'Generate SSH key' 'List SSH keys' 'Backup keys' 'Remove key' || continue
                case "$MENU_SELECTION" in
                    0) break ;;
                    1) bash "$SCRIPT_ROOT/security/keys/keyring.sh" ;;
                    2) bash "$SCRIPT_ROOT/security/keys/generate.sh" ;;
                    3) bash "$SCRIPT_ROOT/security/keys/list.sh" ;;
                    4) bash "$SCRIPT_ROOT/security/keys/backup.sh" ;;
                    5) bash "$SCRIPT_ROOT/security/keys/remove.sh" ;;
                esac
                pause
            done
            ;;
    esac
done
