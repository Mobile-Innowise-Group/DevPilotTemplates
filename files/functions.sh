#!/bin/bash

export HASH_1="hash1.prebuildhash"
export HASH_2="hash2.prebuildhash"
export MODULE_PREBUILD="module_prebuild.sh"
export PREBUILD_DIR=".prebuild"

readonly HASH_1="hash1.prebuildhash"
readonly HASH_2="hash2.prebuildhash"
readonly MODULE_PREBUILD="module_prebuild.sh"
readonly PREBUILD_DIR=".prebuild"

__calculate_hash() {
    local file_path="$1"
    sha256sum "$file_path" | awk '{ print $1 }'
}

__print_usage() {
    echo "Usage: __build_file_hashes -d <directory_path> -o <output_file>"
    echo "  -d  Directory to scan"
    echo "  -o  Output file to store results"
    exit 1
}

__build_file_hashes() {
    local directory=""
    local output_file=""

    while [ $# -gt 0 ]; do
        case "$1" in
            -d) directory="$2"; shift 2 ;;
            -o) output_file="$2"; shift 2 ;;
            *) echo "Unknown option: $1"; __print_usage; return 1 ;;
        esac
    done

    if [ -z "$directory" ] || [ -z "$output_file" ]; then
        __print_usage
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

    new_hash=$(sha256sum "$new_file" | awk '{print $1}')
    old_hash=$(sha256sum "$old_file" | awk '{print $1}')

    if [ "$new_hash" != "$old_hash" ]; then
        return 0
    fi

    return 1
}

run_prebuild_if_needed() {
  local force_run=""
  local compact_output=""
  local dir=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
        force_run=true
        shift
        ;;
      --compact)
        compact_output=true
        shift
        ;;
      *)
        dir="$1"
        shift
        ;;
    esac
  done

  [[ -z "$force_run" ]] && force_run="${FORCE_PREBUILD:-false}"
  [[ -z "$compact_output" ]] && compact_output="${COMPACT_PREBUILD:-false}"

  (
    cd "$dir/$PREBUILD_DIR" || exit

    [ ! -f "$HASH_1" ] && touch "$HASH_1"

    if [ -f "$HASH_2" ]; then
      cp "$HASH_2" "$HASH_1"
    else
      touch "$HASH_2"
    fi

    __build_file_hashes -d ../lib -o "$HASH_2"

    if $force_run || __check_for_mismatches -o "$HASH_1" -n "$HASH_2"; then
      echo -e "\x1B[32m🟢Running $dir $MODULE_PREBUILD \x1B[0m"
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
      echo -e "\x1B[36m🔵Skipping $dir $MODULE_PREBUILD \x1B[0m"
    fi
  )
}
