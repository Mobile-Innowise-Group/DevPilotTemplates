#!/bin/bash

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
