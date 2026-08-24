#!/usr/bin/env bash

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/menu.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
require_interactive
while true; do
    menu_choose 'System services' 'Docker status' 'Install Docker' 'Start Docker' 'Enable Docker' 'Tailscale status' 'Install Tailscale' 'Start Tailscale' 'Enable Tailscale' || continue
    case "$MENU_SELECTION" in
        0) exit 0 ;;
        1)
            bash "$SCRIPT_ROOT/services/docker.sh" status
            pause
            ;;
        2)
            bash "$SCRIPT_ROOT/services/docker.sh" install
            pause
            ;;
        3)
            bash "$SCRIPT_ROOT/services/docker.sh" start
            pause
            ;;
        4)
            bash "$SCRIPT_ROOT/services/docker.sh" enable
            pause
            ;;
        5)
            bash "$SCRIPT_ROOT/services/tailscale.sh" status
            pause
            ;;
        6)
            bash "$SCRIPT_ROOT/services/tailscale.sh" install
            pause
            ;;
        7)
            bash "$SCRIPT_ROOT/services/tailscale.sh" start
            pause
            ;;
        8)
            bash "$SCRIPT_ROOT/services/tailscale.sh" enable
            pause
            ;;
    esac
done
