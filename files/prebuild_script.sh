#!/bin/zsh

source functions.sh

run_prebuild_if_needed core
run_prebuild_if_needed core_ui
run_prebuild_if_needed data
run_prebuild_if_needed domain

for dir in ./features/*(/); do
  run_prebuild_if_needed "$dir"
done

run_prebuild_if_needed navigation
run_prebuild_if_needed .
