#!/bin/bash

source functions.sh

FORCE_PREBUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE_PREBUILD=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

export FORCE_PREBUILD
export -f run_prebuild_if_needed
export -f __build_file_hashes
export -f __check_for_mismatches
export -f __calculate_hash

run_prebuild_if_needed core
run_prebuild_if_needed core_ui
run_prebuild_if_needed data
run_prebuild_if_needed domain

if [ -d 'features' ]; then
  count=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
  find 'features' -mindepth 1 -maxdepth 1 -type d | xargs -n 1 -P "$count" -I {} bash -c '
    run_prebuild_if_needed "$0"
  ' {}
fi

run_prebuild_if_needed navigation
run_prebuild_if_needed .
