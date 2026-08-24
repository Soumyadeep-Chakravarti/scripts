#!/usr/bin/env bash

package_is_installed() {
    local package="$1"
    local package_manager

    package_manager=$(detect_package_manager) || {
        log_error "Unsupported package manager; supported managers: pacman, apt-get."
        return 1
    }

    case "$package_manager" in
        pacman) pacman -Q "$package" > /dev/null 2>&1 ;;
        apt) [[ $(dpkg-query -W -f='${db:Status-Status}' "$package" 2> /dev/null) == installed ]] ;;
    esac
}

packages_install() {
    local package_manager
    local -a command

    (($#)) || {
        log_error "packages_install requires at least one package."
        return 1
    }
    package_manager=$(detect_package_manager) || {
        log_error "Unsupported package manager; supported managers: pacman, apt-get."
        return 1
    }

    case "$package_manager" in
        pacman)
            command=(sudo pacman -S --needed)
            [[ "$ASSUME_YES" == 1 ]] && command+=(--noconfirm)
            command+=(-- "$@")
            ;;
        apt)
            command=(sudo apt-get install)
            [[ "$ASSUME_YES" == 1 ]] && command+=(-y)
            command+=(-- "$@")
            ;;
    esac

    run_mutating "Install packages: $*" "${command[@]}"
}
