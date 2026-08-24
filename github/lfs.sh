#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_command git
require_command git-lfs

for arg in "$@"; do
    parse_common_flag "$arg" || die "Usage: lfs.sh [--dry-run] [--yes]"
done
git rev-parse --is-inside-work-tree > /dev/null 2>&1 || die "Run this utility inside a Git repository."

printf '%bGit LFS utility%b\n\n' "$BOLD" "$RESET"

cat << 'MENU'
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
        run_mutating "Pull Git LFS objects" git lfs pull
        ;;

    4)
        run_mutating "Fetch Git LFS objects" git lfs fetch
        ;;

    5)
        read -r -p "File/pattern to track: " FILE
        [[ -n "$FILE" ]] || exit 0

        run_mutating "Track $FILE with Git LFS" git lfs track "$FILE" || exit 0

        [[ "$DRY_RUN" == 1 ]] && log_info "LFS tracking preview complete." || log_success "Added LFS tracking rule."
        [[ "$DRY_RUN" == 1 ]] || log_info "Remember to commit .gitattributes."
        ;;

    0)
        exit 0
        ;;

    *)
        die "Invalid selection."
        ;;
esac
