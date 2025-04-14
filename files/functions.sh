readonly HASH_1="hash1.prebuildhash"
readonly HASH_2="hash2.prebuildhash"
readonly MODULE_PREBUILD="module_prebuild.sh"

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

    while getopts "d:o:" opt; do
        case "$opt" in
            d) directory="$OPTARG" ;;
            o) output_file="$OPTARG" ;;
            *) __print_usage ;;
        esac
    done

    if [ -z "$directory" ] || [ -z "$output_file" ]; then
        __print_usage
    fi

    if [ ! -d "$directory" ]; then
        echo "Error: Directory '$directory' does not exist." >&2
        return 1
    fi

    if [ ! -f "$output_file" ]; then
        touch "$output_file"
        if [ $? -ne 0 ]; then
            echo "Error: Unable to create output file '$output_file'" >&2
            return 1
        fi
    fi

    truncate -s 0 "$output_file"

    find "$directory" -type f | while read -r file; do
        if [ ! -r "$file" ]; then
            echo "Error: Unable to read file '$file'" >&2
            continue
        fi

        file_hash=$(__calculate_hash "$file")

        if [ $? -ne 0 ]; then
            echo "Error: Failed to calculate hash for '$file'" >&2
            continue
        fi

        echo "$file $file_hash" >> "$output_file"
    done

    sort -o "$output_file" "$output_file"
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

    while IFS=' ' read -r new_path new_hash; do
        old_hash=$(grep "^$new_path " "$old_file" | awk '{print $2}')

        if [ -z "$old_hash" ] || [ "$old_hash" != "$new_hash" ]; then
            return 0
        fi
    done < "$new_file"

    return 1
}

run_prebuild_if_needed() {
  local dir="$1"

  (
    cd "$dir" || exit

    [ ! -f "$HASH_1" ] && touch "$HASH_1"

    if [ -f "$HASH_2" ]; then
      cp "$HASH_2" "$HASH_1"
    else
      touch "$HASH_2"
    fi

    __build_file_hashes -d lib -o "$HASH_2"

    if __check_for_mismatches -o "$HASH_1" -n "$HASH_2"; then
      echo -e "\x1B[36m🔵Running $dir $MODULE_PREBUILD \x1B[0m"
      sh "$MODULE_PREBUILD"
      __build_file_hashes -d lib -o "$HASH_2"
      cp "$HASH_2" "$HASH_1"
    else
      echo -e "\x1B[32m🟢Skipping $dir $MODULE_PREBUILD \x1B[0m"
    fi
  )
}

