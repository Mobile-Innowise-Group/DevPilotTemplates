#!/bin/bash

newBlock=false
file=""
code=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      file="$2"
      shift 2
      ;;
    --code)
      code="$2"
      shift 2
      ;;
    --newBlock)
      newBlock=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$file" || -z "$code" ]]; then
  echo "Missing --file or --code"
  exit 1
fi

if [[ ! -f "$file" ]]; then
  echo "File not found: $file"
  exit 1
fi

lastLineNum=$(grep -n '}' "$file" | tail -n1 | cut -d: -f1)
lastLine=$(sed "${lastLineNum}q;d" "$file")

if [[ "$lastLine" =~ \{[^\}]*\} ]]; then
  newLine="${lastLine%\}} $code }"
  sed "${lastLineNum}s/.*/$newLine/" "$file" > "$file.tmp"
else
  sed "$((lastLineNum-1))q" "$file" > "$file.tmp"
  if [[ "$newBlock" == true ]]; then
    echo "" >> "$file.tmp"
  fi
  echo "  $code" >> "$file.tmp"
  tail -n +"$lastLineNum" "$file" >> "$file.tmp"
fi

mv "$file.tmp" "$file"
