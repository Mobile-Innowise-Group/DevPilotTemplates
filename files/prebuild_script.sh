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

run_prebuild_if_needed core
run_prebuild_if_needed core_ui
run_prebuild_if_needed data
run_prebuild_if_needed domain

if [ -d 'features' ]; then
  for dir in features/*; do
    if [ -d "$dir" ]; then
      run_prebuild_if_needed "$dir"
    fi
  done
fi

run_prebuild_if_needed navigation
run_prebuild_if_needed .
