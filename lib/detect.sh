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

    [[ -r /etc/os-release ]] || return 1
    id=$(
        . /etc/os-release
        printf '%s' "${ID:-}"
    )
    [[ -n "$id" ]] || return 1
    printf '%s\n' "$id"
}

is_wsl() {
    [[ -r /proc/sys/kernel/osrelease ]] || return 1
    [[ $(< /proc/sys/kernel/osrelease) == *[Mm]icrosoft* || $(< /proc/sys/kernel/osrelease) == *WSL* ]]
}
