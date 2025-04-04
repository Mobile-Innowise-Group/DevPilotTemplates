#!/bin/bash

usage() {
    echo "Usage: $0 --from <source_file> --to <destination_file>"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --from)
            from="$2"
            shift 2
            ;;
        --to)
            to="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$from" ] || [ -z "$to" ]; then
    usage
fi

if [ ! -f "$from" ]; then
    echo "Error: Source file '$from' not found!"
    exit 1
fi

cat "$from" >> "$to"
sort -o "$to" "$to"
echo "Content from '$from' has been successfully appended to '$to' and sorted alphabetically."

