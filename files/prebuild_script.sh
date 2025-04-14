#!/bin/bash

source functions.sh

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
