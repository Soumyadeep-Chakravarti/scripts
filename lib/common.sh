#!/usr/bin/env bash

# Don't use set -euo here.
# Individual scripts decide their own error-handling policy.

# ─────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────

if [[ -t 1 ]]; then
    RESET='\033[0m'
    BOLD='\033[1m'
    RED='\033[31m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    BLUE='\033[34m'
    MAGENTA='\033[35m'
    CYAN='\033[36m'
    WHITE='\033[37m'
else
    RESET=''
    BOLD=''
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    WHITE=''
fi

# ─────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────

log_info() {
    printf '%b[INFO]%b %s\n' "$CYAN" "$RESET" "$*"
}

log_success() {
    printf '%b[ OK ]%b %s\n' "$GREEN" "$RESET" "$*"
}

log_warn() {
    printf '%b[WARN]%b %s\n' "$YELLOW" "$RESET" "$*"
}

log_error() {
    printf '%b[ERROR]%b %s\n' "$RED" "$RESET" "$*" >&2
}

die() {
    log_error "$*"
    exit 1
}

# ─────────────────────────────────────────────
# Commands
# ─────────────────────────────────────────────

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_command() {
    local cmd

    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            die "Required command not found: $cmd"
        fi
    done
}

# ─────────────────────────────────────────────
# User interaction
# ─────────────────────────────────────────────

confirm() {
    local prompt="${1:-Continue?}"

    local answer

    read -r -p "$prompt [y/N] " answer

    case "$answer" in
        y|Y|yes|YES|Yes)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

pause() {
    printf '\n'
    read -r -p "Press Enter to continue..." _
}

# ─────────────────────────────────────────────
# UI
# ─────────────────────────────────────────────

print_banner() {
    printf '%b' "$BOLD"
    printf '%s\n' '╔══════════════════════════════════════╗'
    printf '%s\n' '║          SYSTEM AUTOMATION           ║'
    printf '%s\n' '╚══════════════════════════════════════╝'
    printf '%b\n' "$RESET"
}
