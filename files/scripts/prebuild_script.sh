#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -f, --force       Force run the module_prebuild.sh regardless of file changes.
  -v, --verbose     Enable verbose output (prints prebuild script output).
  -h, --help        Show this help message and exit.

Description:
  This script walks through the project and runs a prebuild script (./.prebuild/module_prebuild.sh)
  inside each module, only if the contents have changed (based on file hash comparison) — unless forced via -f.

  Modules processed:
    - core
    - core_ui
    - data
    - domain
    - features (each subdirectory)
    - navigation
    - root project directory

EOF
  exit 0
fi

source functions.sh

export -f echo_styled
export -f module_flow

FORCE=false
VERBOSE=false

export FORCE
export VERBOSE

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force) FORCE=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

[ ! -f "pubspec.yaml" ] && cd ../

(
    cd core || exit
    module_flow -g "lib" -g "*.yaml" -g "resources"
)

(
    cd core_ui || exit
    module_flow -g "lib" -g "*.yaml"
)

(
    cd data || exit
    module_flow -g "lib" -g "*.yaml"
)

(
    cd domain || exit
    module_flow -g "lib" -g "*.yaml"
)

(
    cd features || exit
    find . -mindepth 1 -maxdepth 1 -type d -exec bash -c 'cd "$0" && module_flow -g "lib" -g "*.yaml"' {} \;
)

(
    cd navigation || exit
    module_flow -g "lib" -g "*.yaml"
)

(
    module_flow -g "lib" -g "*.yaml"
)
