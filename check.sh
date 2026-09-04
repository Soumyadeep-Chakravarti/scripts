#!/usr/bin/env bash

set -o pipefail

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/profile.sh"

usage() {
    printf 'Usage: %s [--profile wsl-arch|ubuntu-dev] [--dry-run] [--yes]\n' "${0##*/}"
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

[[ "$DRY_RUN" == 1 ]] && log_info '--dry-run has no effect: check is read-only.'
[[ "$ASSUME_YES" == 1 ]] && log_info '--yes has no effect: check does not prompt.'

if [[ -z "$profile" ]]; then
    profile=$(profile_default) || die 'Cannot select a profile automatically; pass --profile.'
fi
profile_load "$profile" || exit 1

status=0
if command_exists bash; then
    log_success "Bash is available."
else
    log_error 'Bash is required.'
    status=1
fi

profile_verify_environment || exit 1
log_success "Profile $PROFILE_NAME matches this environment."

if [[ ${#PROFILE_PACKAGES[@]} -gt 0 ]]; then
    log_success "Profile declares ${#PROFILE_PACKAGES[@]} foundation package(s)."
else
    log_error "Profile $PROFILE_NAME has no declared packages."
    status=1
fi

exit "$status"
