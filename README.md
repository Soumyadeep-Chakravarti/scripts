# System automation scripts

This repository provides interactive workstation automation. It supports only the
`wsl-arch` and `ubuntu-dev` profiles; all other profile names are rejected.

## Usage

```bash
bash check.sh [--profile wsl-arch|ubuntu-dev] [--dry-run] [--yes]
bash bootstrap.sh [--profile wsl-arch|ubuntu-dev] [--dry-run] [--yes]
bash setup/system.sh [--profile wsl-arch|ubuntu-dev] [--dry-run] [--yes]
```

`check.sh` is read-only. It validates Bash, the selected profile declaration, OS,
WSL requirement, and package-manager match. `bootstrap.sh` selects a profile and
opens Development, Desktop, GitHub, Maintenance, Projects, Security, and System
menus.

`setup/system.sh` is the non-interactive baseline setup entry point. It validates
the profile, installs the profile's foundation, shell, CLI, and development tools,
deploys dotfiles, and verifies the expected commands. It intentionally leaves
GitHub authentication, service activation, and optional security hardening
explicit.

State-changing actions source `lib/common.sh` and use `run_mutating`. It prints
commands without running them with `--dry-run`, asks for confirmation by default,
and accepts confirmation with `--yes`. `lib/packages.sh` supplies
`packages_install` for `pacman` and `apt-get`; unsupported package managers fail
clearly. No system state changes merely by sourcing helpers or running checks.

The setup menu can install base tools, Docker, the dotfiles links, keyring tools,
Neovim, Nix, runtimes, and shell integrations. System actions manage Docker and
Tailscale; desktop actions are blocked under WSL. Project, GitHub, maintenance,
and security actions are available from their corresponding menus.

SSH hardening is preview-only until `--apply`, and exits on WSL. Firewall setup
is status-only until `--install`; it does not create access rules. SSH key backup
exports public keys by default. Backing up private keys requires
`--include-private` and typing `BACKUP PRIVATE KEY` interactively.
