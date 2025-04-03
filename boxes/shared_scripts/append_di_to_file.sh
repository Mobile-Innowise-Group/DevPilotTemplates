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

NEW_DEP="\n $(echo "$CODE_TO_INSERT" | tr -d '\n')"
#NEW_DEP="\n    $CODE_TO_INSERT"
COUNTER=0

awk -v method="$METHOD_NAME" -v dep="$NEW_DEP" '
{
    # Case 1: If method ends with {}
    if ($0 ~ "(void|Future<void>) *" method "\\(.*\\) *(async )?\\{\\}") {
        sub(/\{\}/, "{\n" dep "\n  }", $0)  # Insert code inside the braces
        print
        next
    }

    # Case 2: If method body is not empty
    if ($0 ~ "(void|Future<void>) *" method "\\(.*\\) *(async )?\\{") {
        COUNTER = 1
        print
        next
    }

    # Case 3: Inside the method, looking for closing brace to insert code
    if (COUNTER > 0) {
        if ($0 ~ /\{/) {
            COUNTER += 1
        } else if ($0 ~ /\}/) {
            COUNTER -= 1
            if (COUNTER == 0) {
                print dep
            }
        }
    }

    print
}
' "$FILE" > temp.dart && mv temp.dart "$FILE"

dart format "$FILE" > /dev/null 2>&1

echo "Code inserted successfully into $METHOD_NAME in $FILE!"
