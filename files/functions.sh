#!/bin/bash

readonly HASH_1="hash1.prebuildhash"
readonly HASH_2="hash2.prebuildhash"
readonly MODULE_PREBUILD="module_prebuild.sh"
readonly PREBUILD_DIR=".prebuild"

export PREBUILD_DIR HASH_1 HASH_2 MODULE_PREBUILD

readonly COLOR_GREEN="\x1B[32m"
readonly COLOR_BLUE="\x1B[36m"
readonly COLOR_RED="\x1B[31m"
readonly COLOR_RESET="\x1B[0m"

export COLOR_GREEN COLOR_BLUE COLOR_RED COLOR_RESET

__calculate_hash() {
  local file_path="$1"
  sha256sum "$file_path" | awk '{ print $1 }'
}

__build_file_hashes() {
  local directory=""
  local output_file=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -d) directory="$2"; shift 2 ;;
      -o) output_file="$2"; shift 2 ;;
      *) echo "Unknown option: $1" ;;
    esac
  done

  if [ -z "$directory" ] || [ -z "$output_file" ]; then
    echo "Error: Both -d (directory) and -o (output_file) are required." >&2
    return 1
  fi

  if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist." >&2
    return 1
  fi

  local hash
  hash=$(find "$directory" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{ print $1 }')

  if [ $? -ne 0 ]; then
    echo "Error: Failed to calculate directory hash for '$directory'" >&2
    return 1
  fi

  echo "$hash" > "$output_file"
}

__check_for_mismatches() {
  local new_file=""
  local old_file=""

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -n|--new_file) new_file="$2"; shift 2 ;;
      -o|--old_file) old_file="$2"; shift 2 ;;
      *) echo "Unknown parameter: $1"; return 1 ;;
    esac
  done

  if [ -z "$new_file" ] || [ -z "$old_file" ]; then
    echo "Error: Both -n (new_file) and -o (old_file) are required." >&2
    return 1
  fi

  if [ ! -f "$new_file" ]; then
    echo "Error: New file '$new_file' does not exist." >&2
    return 1
  fi

  if [ ! -f "$old_file" ]; then
    echo "Error: Old file '$old_file' does not exist." >&2
    return 1
  fi

  local new_hash old_hash
  new_hash=$(sha256sum "$new_file" | awk '{print $1}')
  old_hash=$(sha256sum "$old_file" | awk '{print $1}')

  [[ "$new_hash" != "$old_hash" ]]
}

run_prebuild_if_needed() {
  local force_run=""
  local compact_output=""
  local dir=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force) force_run=true; shift ;;
      --compact) compact_output=true; shift ;;
      *) dir="$1"; shift ;;
    esac
  done

  [[ -z "$force_run" ]] && force_run="${FORCE_PREBUILD:-false}"
  [[ -z "$compact_output" ]] && compact_output="${COMPACT_PREBUILD:-false}"

  (
    set -euo pipefail

    handle_error() {
      echo -e "${COLOR_RED}🔴Error occurred while processing '$dir'. Cleaning up hash files and skipping module${COLOR_RESET}"
      [[ -n "${abs_hash_1:-}" && -f "$abs_hash_1" ]] && rm -f "$abs_hash_1"
      [[ -n "${abs_hash_2:-}" && -f "$abs_hash_2" ]] && rm -f "$abs_hash_2"
      exit 0
    }

    trap 'handle_error' ERR

    cd "$dir/$PREBUILD_DIR"

    [ ! -f "$HASH_1" ] && touch "$HASH_1"
    [ -f "$HASH_2" ] && cp "$HASH_2" "$HASH_1" || touch "$HASH_2"

    abs_hash_1="$(realpath "$HASH_1")"
    abs_hash_2="$(realpath "$HASH_2")"

    __build_file_hashes -d ../lib -o "$HASH_2"

    if $force_run || __check_for_mismatches -o "$HASH_1" -n "$HASH_2"; then
      echo -e "${COLOR_GREEN}🟢Running $dir $MODULE_PREBUILD${COLOR_RESET}"
      cd ../

      if $compact_output; then
        sh "$PREBUILD_DIR/$MODULE_PREBUILD" > /dev/null
      else
        sh "$PREBUILD_DIR/$MODULE_PREBUILD"
      fi

      cd "$PREBUILD_DIR"
      __build_file_hashes -d ../lib -o "$HASH_2"
      cp "$HASH_2" "$HASH_1"
    else
      echo -e "${COLOR_BLUE}🔵Skipping $dir $MODULE_PREBUILD${COLOR_RESET}"
    fi
  )
}
