#!/bin/bash

METHOD_NAME=""
CODE_TO_INSERT=""
FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file)
            FILE="$2"
            shift 2
            ;;
        --method)
            METHOD_NAME="$2"
            shift 2
            ;;
        --code)
            CODE_TO_INSERT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$FILE" || -z "$METHOD_NAME" || -z "$CODE_TO_INSERT" ]]; then
    echo "Usage: $0 --file <filename> --method <method_name> --code '<code_to_insert>'"
    exit 1
fi

NEW_DEP="\n    $CODE_TO_INSERT"

if grep -qE "static void $METHOD_NAME\(.*\) *{}" "$FILE"; then
    sed -i.bak -E "s|(static void $METHOD_NAME\(.*\)) *\{\}|\1 {\n$NEW_DEP\n}|" "$FILE" && rm "$FILE.bak"
else
    awk -v method="$METHOD_NAME" -v dep="$NEW_DEP" '
    $0 ~ "static void " method "\\(" { in_method = 1 }
    in_method && $0 ~ /^  \}/ {
        if (!inserted) { print dep; inserted=1 } # Insert even in an empty method
    }
    { print }
    ' "$FILE" > temp.dart && mv temp.dart "$FILE"
fi

dart format "$FILE" > /dev/null 2>&1

echo "Dependency added successfully to $METHOD_NAME in $FILE!"
