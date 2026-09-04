#!/usr/bin/env bash

PROFILE_DIR="${PROFILE_DIR:-${SCRIPT_ROOT:-$(pwd)}/profiles}"

profile_supported() {
    case "$1" in
        wsl-arch | arch | ubuntu-dev) return 0 ;;
        *) return 1 ;;
    esac
}

profile_default() {
    local os_id package_manager

    os_id=$(detect_os_id) || return 1
    package_manager=$(detect_package_manager) || return 1

    if [[ "$os_id" == arch && "$package_manager" == pacman ]] && is_wsl; then
        printf '%s\n' wsl-arch
    elif [[ "$os_id" == arch && "$package_manager" == pacman ]]; then
        printf '%s\n' arch
    elif [[ "$os_id" == ubuntu && "$package_manager" == apt ]]; then
        printf '%s\n' ubuntu-dev
    else
        return 1
    fi
}

profile_load() {
    local profile="$1"
    local profile_file

    profile_supported "$profile" || {
        log_error "Unsupported profile: $profile (supported: wsl-arch, arch, ubuntu-dev)"
        return 1
    }

    profile_file="$PROFILE_DIR/$profile.conf"
    [[ -r "$profile_file" ]] || {
        log_error "Profile configuration is missing: $profile_file"
        return 1
    }

    unset PROFILE_NAME PROFILE_DESCRIPTION PROFILE_OS_ID PROFILE_REQUIRES_WSL PROFILE_PACKAGE_MANAGER
    PROFILE_FOUNDATION_PACKAGES=()
    PROFILE_SHELL_PACKAGES=()
    PROFILE_CLI_PACKAGES=()
    PROFILE_DEV_PACKAGES=()
    PROFILE_PACKAGES=()
    PROFILE_COMMANDS=()

    # Profile files are repository-maintained declarations, not user input.
    source "$profile_file"

    if [[ 
        "$PROFILE_NAME" != "$profile" ||
        -z "$PROFILE_DESCRIPTION" ||
        -z "$PROFILE_OS_ID" ||
        -z "$PROFILE_PACKAGE_MANAGER" ||
        ${#PROFILE_PACKAGES[@]} -eq 0 ||
        ${#PROFILE_COMMANDS[@]} -eq 0 ]] \
        ; then
        log_error "Invalid profile configuration: $profile_file"
        return 1
    fi
}

profile_verify_environment() {
    local os_id package_manager

    os_id=$(detect_os_id) || {
        log_error "Cannot determine the operating system."
        return 1
    }
    package_manager=$(detect_package_manager) || {
        log_error "No supported package manager found (pacman or apt-get required)."
        return 1
    }

    [[ "$os_id" == "$PROFILE_OS_ID" ]] || {
        log_error "Profile $PROFILE_NAME requires $PROFILE_OS_ID; detected $os_id."
        return 1
    }
    [[ "$package_manager" == "$PROFILE_PACKAGE_MANAGER" ]] || {
        log_error "Profile $PROFILE_NAME requires $PROFILE_PACKAGE_MANAGER; detected $package_manager."
        return 1
    }
    if [[ "${PROFILE_REQUIRES_WSL:-0}" == 1 ]] && ! is_wsl; then
        log_error "Profile $PROFILE_NAME requires WSL."
        return 1
    fi
}
