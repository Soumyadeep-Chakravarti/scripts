#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/profile.sh"
source "$SCRIPT_ROOT/lib/packages.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
action_parse_flags "$@"
profile=''
while ((${#ACTION_ARGS[@]})); do
    case "${ACTION_ARGS[0]}" in
        --profile)
            ((${#ACTION_ARGS[@]} >= 2)) || die '--profile requires a value.'
            profile="${ACTION_ARGS[1]}"
            ACTION_ARGS=("${ACTION_ARGS[@]:2}")
            ;;
        *) die "Unknown option: ${ACTION_ARGS[0]}" ;;
    esac
done
if [[ -z "$profile" ]]; then
    profile=$(profile_default) || die 'Cannot select a profile automatically; pass --profile.'
fi
profile_load "$profile" || exit 1
profile_verify_environment || exit 1
packages_install "${PROFILE_PACKAGES[@]}"
