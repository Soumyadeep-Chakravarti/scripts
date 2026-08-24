#!/usr/bin/env bash

menu_choose() {
    local title="$1"
    shift
    local choice index=1
    local -a entries=("$@")

    printf '\n%s\n' "$title"
    for choice in "${entries[@]}"; do
        printf '  %d) %s\n' "$index" "$choice"
        ((index++))
    done
    printf '  0) Back\n'

    if [[ ! -t 0 ]]; then
        log_error "An interactive terminal is required for menus."
        return 1
    fi
    read -r -p 'Select an option: ' choice
    [[ "$choice" =~ ^[0-9]+$ ]] || return 1
    ((choice >= 0 && choice <= ${#entries[@]})) || return 1
    MENU_SELECTION="$choice"
}

menu_category() {
    local title="$1"

    printf '\n%s\n' "$title"
    log_info "This foundation menu has no actions wired yet."
    pause
}
