#!/usr/bin/env bash

detect_package_manager() {
    if command_exists pacman; then
        printf '%s\n' pacman
    elif command_exists apt-get; then
        printf '%s\n' apt
    else
        return 1
    fi
}

detect_os_id() {
    local id

    if [[ -r /etc/os-release ]]; then
        id=$(
            . /etc/os-release
            printf '%s' "${ID:-}"
        )
        [[ -n "$id" ]] && {
            printf '%s\n' "$id"
            return 0
        }
    fi

    # Minimal PRoot Arch roots may not include os-release.
    command_exists pacman && printf '%s\n' arch
}

is_wsl() {
    [[ -r /proc/sys/kernel/osrelease ]] || return 1
    [[ $(< /proc/sys/kernel/osrelease) == *[Mm]icrosoft* || $(< /proc/sys/kernel/osrelease) == *WSL* ]]
}
