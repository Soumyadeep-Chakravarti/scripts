#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_command git

printf '%bGit LFS utility%b\n\n' "$BOLD" "$RESET"

cat <<'MENU'
  1) Show LFS files in current repository
  2) Show LFS status
  3) Pull LFS objects
  4) Fetch LFS objects
  5) Track a file
  0) Back

MENU

read -r -p "Select: " CHOICE

case "$CHOICE" in

    1)
        git lfs ls-files
        ;;

    2)
        git lfs status
        ;;

    3)
        git lfs pull
        ;;

    4)
        git lfs fetch
        ;;

    5)
        read -r -p "File/pattern to track: " FILE
        [[ -n "$FILE" ]] || exit 0

        git lfs track "$FILE"

        log_success "Added LFS tracking rule."
        log_info "Remember to commit .gitattributes."
        ;;

    0)
        exit 0
        ;;

    *)
        die "Invalid selection."
        ;;
esac
