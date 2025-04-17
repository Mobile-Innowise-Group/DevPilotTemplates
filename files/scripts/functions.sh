#!/bin/bash

export COLOR_RED=31
export COLOR_GREEN=32
export COLOR_BLUE=36

function echo_styled() {
    echo -e "\033[1;$2m$1\033[0m"
}

function module_flow() {
  set -eo pipefail

  local PREBUILD_DIR=".prebuild"
  local HASH_FILE="hash.prebuildhash"
  local PREBUILD_FILE="module_prebuild.sh"

  local globs=()

  function on_error() {
    local exit_code=$?
    echo_styled "🔴Error while processing $(pwd)" "$COLOR_RED"
    [[ -n "${abs_hash:-}" && -f "$abs_hash" ]] && rm -f "$abs_hash"
    exit $exit_code
  }

  trap 'on_error' ERR

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -g) globs+=("$2"); shift 2 ;;
      *) echo "Unknown parameter: $1"; return 1 ;;
    esac
  done

  if [ ${#globs[@]} -eq 0 ]; then
    echo "Error: At least one -g (globs) is required." >&2
    return 1
  fi

  local merged="${globs[@]}"
  local hash=$(find $merged -type f -exec sha256sum {} \; | sort | sha256sum | awk '{ print $1 }')

  cd "$PREBUILD_DIR"

  [ ! -f "$HASH_FILE" ] && touch "$HASH_FILE"

  abs_hash="$(realpath "$HASH_FILE")"

  local old_hash=$(<$HASH_FILE)
  echo "$hash" > "$HASH_FILE"

  if $FORCE || [ "$hash" != "$old_hash" ]; then
    echo_styled "🟢Running $PREBUILD_FILE inside $(pwd)" "$COLOR_GREEN"

    cd ../

    if $VERBOSE; then
      sh "./$PREBUILD_DIR/$PREBUILD_FILE"
    else
      sh "./$PREBUILD_DIR/$PREBUILD_FILE" > /dev/null
    fi

    local new_hash=$(find $merged -type f -exec sha256sum {} \; | sort | sha256sum | awk '{ print $1 }')
    cd "$PREBUILD_DIR"
    echo "$new_hash" > "$HASH_FILE"
  else
    echo_styled "🔵Skipping $PREBUILD_FILE inside $(pwd)" "$COLOR_BLUE"
  fi

  trap - ERR
}