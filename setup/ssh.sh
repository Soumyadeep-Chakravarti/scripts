#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

SSH_DIR="$HOME/.ssh"
CONFIG="$SSH_DIR/config"
AUTOMATION_KEY="$SSH_DIR/github-automation"

for arg in "$@"; do
    parse_common_flag "$arg" || die "Usage: ssh.sh [--dry-run] [--yes]"
done

if [[ ! -f "$AUTOMATION_KEY" ]]; then
    die "github-automation identity does not exist. Run security/keys/generate.sh first."
fi

block=$'# BEGIN github-automation\nHost github-automation\n    HostName github.com\n    User git\n    IdentityFile ~/.ssh/github-automation\n    IdentitiesOnly yes\n# END github-automation'

if [[ -f "$CONFIG" ]]; then
    has_start=0 has_end=0
    grep -Fqx '# BEGIN github-automation' "$CONFIG" && has_start=1 || true
    grep -Fqx '# END github-automation' "$CONFIG" && has_end=1 || true
    [[ "$has_start" == "$has_end" ]] || die "Refusing to modify an incomplete github-automation block in $CONFIG"
    [[ "$has_start" == 1 ]] && log_info "github-automation SSH configuration block already exists; it will be refreshed."
fi

run_mutating "Manage the github-automation SSH configuration block" bash -c '
    set -euo pipefail
    ssh_dir=$1 config=$2 block=$3
    umask 077
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    touch "$config"
    chmod 600 "$config"
    temp=$(mktemp "${config}.tmp.XXXXXX")
    trap "rm -f \"$temp\"" EXIT
    if grep -Fqx "# BEGIN github-automation" "$config" && grep -Fqx "# END github-automation" "$config"; then
        awk '\''BEGIN { skip=0 } /^# BEGIN github-automation$/ { skip=1; next } /^# END github-automation$/ { skip=0; next } !skip { print }'\'' "$config" > "$temp"
    else
        cp "$config" "$temp"
    fi
    [[ ! -s "$temp" || $(tail -c 1 "$temp" 2>/dev/null || true) == $'\''\n'\'' ]] || printf "\n" >> "$temp"
    printf "%s\n" "$block" >> "$temp"
    chmod 600 "$temp"
    mv "$temp" "$config"
' _ "$SSH_DIR" "$CONFIG" "$block"
