#!/usr/bin/env bash
set -o pipefail
SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
source "$SCRIPT_ROOT/lib/detect.sh"
source "$SCRIPT_ROOT/lib/packages.sh"
source "$SCRIPT_ROOT/lib/actions.sh"
action_parse_flags "$@"
((${#ACTION_ARGS[@]} == 0)) || die "Unknown option: ${ACTION_ARGS[0]}"

install_npm_packages() {
    require_command npm
    run_mutating 'Install Neovim npm tools' npm install --global \
        basedpyright \
        eslint_d \
        prettier \
        typescript \
        typescript-language-server \
        vscode-langservers-extracted \
        yaml-language-server
}

bootstrap_neovim() {
    require_command nvim
    run_mutating 'Install Neovim plugins and Mason tools' nvim --headless \
        '+Lazy! sync' \
        '+MasonInstall lua_ls basedpyright rust_analyzer clangd gopls ts_ls jsonls yamlls taplo nil_ls' \
        '+qa'
}

[[ "$(detect_package_manager)" == pacman ]] || die 'Neovim setup currently supports Arch Linux only.'

packages_install \
    neovim \
    git \
    ripgrep \
    fd \
    nodejs \
    npm \
    python \
    ruff \
    rust \
    go \
    clang \
    stylua \
    taplo-cli \
    shfmt \
    shellcheck \
    yamllint \
    markdownlint-cli \
    nixfmt-rfc-style

install_npm_packages
bootstrap_neovim
