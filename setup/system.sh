#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/profile.sh"

usage() {
    printf 'Usage: %s [--profile wsl-arch|arch|ubuntu-dev] [--dry-run] [--yes]\n' "${0##*/}"
}

profile=''
while (($#)); do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || die '--profile requires a value.'
            profile="$2"
            shift 2
            ;;
        --help | -h)
            usage
            exit 0
            ;;
        *)
            if parse_common_flag "$1"; then
                shift
            else
                die "Unknown option: $1"
            fi
            ;;
    esac
done

if [[ -z "$profile" ]]; then
    profile=$(profile_default) || die 'Cannot select a profile automatically; pass --profile.'
fi
profile_load "$profile" || exit 1
profile_verify_environment || exit 1

verify_baseline() {
    local command

    for command in "${PROFILE_COMMANDS[@]}"; do
        if command_exists "$command"; then
            log_success "$command"
        else
            log_error "Required command is unavailable: $command"
            return 1
        fi
    done
    log_success 'Tooling baseline verified.'
}

normalize_commands() {
    case "$PROFILE_PACKAGE_MANAGER" in
        apt)
            if ! command_exists bat && command_exists batcat; then
                run_mutating 'Create bat compatibility link' bash -c 'mkdir -p "$1/.local/bin" && ln -sfn "$2" "$1/.local/bin/bat"' _ "$HOME" "$(command -v batcat)"
            fi
            if ! command_exists fd && command_exists fdfind; then
                run_mutating 'Create fd compatibility link' bash -c 'mkdir -p "$1/.local/bin" && ln -sfn "$2" "$1/.local/bin/fd"' _ "$HOME" "$(command -v fdfind)"
            fi
            ;;
    esac
}

log_info "Setting up $PROFILE_DESCRIPTION."
DRY_RUN="$DRY_RUN" ASSUME_YES="$ASSUME_YES" bash "$SCRIPT_ROOT/setup/base-tools.sh" --profile "$profile"
normalize_commands
DRY_RUN="$DRY_RUN" ASSUME_YES="$ASSUME_YES" bash "$SCRIPT_ROOT/setup/dotfiles.sh"

if [[ "$DRY_RUN" == 1 ]]; then
    log_info 'Dry run complete. Tool verification was skipped.'
else
    verify_baseline
fi
