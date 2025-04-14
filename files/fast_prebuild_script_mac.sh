#!/bin/bash

source functions.sh

run_prebuild_if_needed core
run_prebuild_if_needed core_ui
run_prebuild_if_needed data
run_prebuild_if_needed domain

count=$(find ./features -mindepth 1 -maxdepth 1 -type d | wc -l)
find ./features -mindepth 1 -maxdepth 1 -type d | xargs -n 1 -P "$count" -I {} bash -c 'source functions.sh; run_prebuild_if_needed "$@"' _ {}

run_prebuild_if_needed navigation
run_prebuild_if_needed .