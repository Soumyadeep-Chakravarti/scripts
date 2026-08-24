#!/usr/bin/env bash

SCRIPT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$SCRIPT_ROOT/lib/common.sh"
exec bash "$SCRIPT_ROOT/projects/project-menu.sh"
