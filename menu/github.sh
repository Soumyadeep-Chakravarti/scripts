#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

while true; do
    clear 2>/dev/null || true

    print_banner

    cat <<'MENU'
GitHub / Git

  1) Authenticate GitHub CLI
  2) Configure automation SSH
  3) Clone all repositories
  4) Sync all repositories
  5) Backup GitHub metadata
  6) Git LFS
  0) Back

MENU

    read -r -p "Select: " CHOICE

    case "$CHOICE" in

        1)
            bash "$SCRIPT_DIR/setup/github.sh"
            pause
            ;;

        2)
            bash "$SCRIPT_DIR/setup/ssh.sh"
            pause
            ;;

        3)
            bash "$SCRIPT_DIR/github/clone-all.sh"
            pause
            ;;

        4)
            bash "$SCRIPT_DIR/github/sync-all.sh"
            pause
            ;;

        5)
            bash "$SCRIPT_DIR/github/backup.sh"
            pause
            ;;

        6)
            bash "$SCRIPT_DIR/github/lfs.sh"
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
