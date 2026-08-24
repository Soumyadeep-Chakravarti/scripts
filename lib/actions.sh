#!/usr/bin/env bash

action_parse_flags() {
    ACTION_ARGS=()
    while (($#)); do
        if ! parse_common_flag "$1"; then
            ACTION_ARGS+=("$1")
        fi
        shift
    done
}

require_interactive() {
    [[ -t 0 ]] || die 'An interactive terminal is required for this action.'
}

require_native_desktop() {
    require_interactive
    is_wsl && die 'Desktop installation is not supported under WSL.'
}

service_command() {
    command_exists systemctl || die 'systemctl is required to manage services.'
}
