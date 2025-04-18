#!/bin/bash

# ===============================
# Append and sort function
# Usage: append_exports from=<source_file> to=<destination_file>
# ===============================
append_exports() {
    local from=""
    local to=""

    for arg in "$@"; do
        case $arg in
            from=*)
                from="${arg#*=}"
                ;;
            to=*)
                to="${arg#*=}"
                ;;
            *)
                echo "Unknown argument: $arg"
                return 1
                ;;
        esac
    done

    if [[ -z "$from" || -z "$to" ]]; then
        echo "Usage: append_exports from=<source_file> to=<destination_file>"
        return 1
    fi

    if [ ! -f "$from" ]; then
        echo "Error: Source file '$from' not found!"
        return 1
    fi

    cat "$from" >> "$to"
    dart format "$to" > /dev/null
}

# ===============================
# Insert Code Into Method Function
# Usage: insert_code_into_method file=<filename> method=<method_name> code='<code_to_insert>'
#
# Description:
#   This function inserts the provided code into the specified method of a given file.
#   The insertion occurs based on method signature and braces depth, allowing it to
#   handle both empty and non-empty methods correctly. It ensures the method is found
#   and properly modified, with the new code inserted in the right place.
#
# Arguments:
#   - file=<filename>      : The path to the file where the method resides.
#   - method=<method_name> : The name of the method where the code will be inserted.
#   - code=<code_to_insert>: The code to be inserted inside the method.
#
# Example:
#   insert_code_into_method file="src/my_class.dart" method="myMethod" code="print('Hello, World!');"
#
# The code will be inserted inside the method `myMethod` in the file `src/my_class.dart`.
insert_code_into_method() {
    local file=""
    local method=""
    local code=""

    for arg in "$@"; do
        case $arg in
            file=*) file="${arg#*=}" ;;
            method=*) method="${arg#*=}" ;;
            code=*) code="${arg#*=}" ;;
            *) echo "Unknown argument: $arg" && return 1 ;;
        esac
    done

    if [[ -z "$file" || -z "$method" || -z "$code" ]]; then
        echo "Usage: insert_code_into_method file=<filename> method=<method_name> code='<code_to_insert>'"
        return 1
    fi

    # Escape code block for awk
    local escaped_code=""
    while IFS= read -r line; do
        line="${line//\\/\\\\}"
        line="${line//\"/\\\"}"
        escaped_code+="print \"  $line\";\n"
    done <<< "$code"

    awk -v method="$method" -v code_block="$escaped_code" '
    BEGIN {
        in_method = 0
        brace_depth = 0
    }

    function inject_code() {
        print ""
        cmd = "awk '\''BEGIN{" code_block "}'\''"
        while ((cmd | getline line) > 0) {
            print line
        }
        close(cmd)
    }

    {
        if ($0 ~ "(void|Future<void>) *" method "\\(.*\\) *(async)? *\\{ *\\}") {
            sub(/\{\s*\}/, "{", $0)
            print
            inject_code()
            print "  }"
            next
        }

        if ($0 ~ "(void|Future<void>) *" method "\\(.*\\) *(async)? *\\{") {
            in_method = 1
            brace_depth = 1
            print
            next
        }

        if (in_method) {
            if ($0 ~ /\{/) brace_depth++
            if ($0 ~ /\}/) brace_depth--

            if (brace_depth == 0) {
                inject_code()
                in_method = 0
            }
            print
            next
        }

        print
    }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

    dart format "$file" > /dev/null
}

# ===============================
# Copy directory contents safely
# Usage: copy_source_files from=<src_dir> to=<dest_dir>
#
# Ensures the source directory exists.
# If valid, it copies all files from the source to the destination,
# creating the destination directory if it doesn't exist.
# ===============================
copy_source_files() {
    local from=""
    local to=""

    for arg in "$@"; do
        case $arg in
            from=*) from="${arg#*=}" ;;
            to=*) to="${arg#*=}" ;;
            *) echo "Unknown argument: $arg" && return 1 ;;
        esac
    done

    if [[ -z "$from" || -z "$to" ]]; then
        echo "Usage: copy_source_files from=<src_dir> to=<dest_dir>"
        return 1
    fi

    if [ ! -d "$from" ]; then
        echo "Error: Source directory '$from' not found!"
        return 1
    fi

    mkdir -p "$to"
    cp -r "$from"/* "$to"
}

# ===============================
# Validate project root
# Usage: ensure_valid_project_root <project_path>
# ===============================
ensure_valid_project_root() {
    local project_path="$1"

    if [ -z "$project_path" ]; then
        echo "Error: Specify path to a project root"
        exit 1
    fi

    if [ ! -f "$project_path/pubspec.yaml" ]; then
        echo "Error: pubspec.yaml not found in project root: $project_path"
        exit 1
    fi
}

# ===============================
# Add a Dart dependency to a project
# Usage: add_dependency project_dir=<project_dir> dependency=<dependency> [--dev]
# ===============================
add_dependency() {
    local project_dir=""
    local dependency=""
    local is_dev=false

    for arg in "$@"; do
        case $arg in
            project_dir=*) project_dir="${arg#*=}" ;;
            dependency=*) dependency="${arg#*=}" ;;
            --dev) is_dev=true ;;
            *) echo "Unknown argument: $arg" && return 1 ;;
        esac
    done

    if [ -z "$project_dir" ] || [ -z "$dependency" ]; then
        echo "Error: Both project directory and dependency are required."
        return 1
    fi

    (
      cd "$project_dir" || exit
      if $is_dev; then
        dart pub add --dev "$dependency" > /dev/null
      else
        dart pub add "$dependency" > /dev/null
      fi
    )
}

##
# @function inject_member
# @brief Injects Dart member code before the last closing brace in a file.
#
# @param file="<filename>"       Path to the target Dart file.
# @param code="<code string>"    Code to inject (supports multi-line).
# @flag  --newBlock              Optional: adds a blank line before the new code.
#
# @example
#    constantsCode=$(cat <<EOF
#     static const String appDatabaseName = 'appDatabase';
#     static const int appDatabaseVersion = 1;
#   EOF
#   )
#   inject_member file="lib/consts.dart" code="$constantsCode" --newBlock
##
inject_member() {
  local file=""
  local code=""
  local newBlock=false

  for arg in "$@"; do
    case "$arg" in
      file=*) file="${arg#*=}" ;;
      code=*) code="${arg#*=}" ;;
      --newBlock) newBlock=true ;;
      *) echo "Unknown option: $arg" >&2; return 1 ;;
    esac
  done

  if [[ -z "$file" || -z "$code" ]]; then
    echo "Missing file= or code=" >&2
    return 1
  fi

  if [[ ! -f "$file" ]]; then
    echo "File not found: $file" >&2
    return 1
  fi

  local lastLineNum
  lastLineNum=$(grep -n '}' "$file" | tail -n1 | cut -d: -f1)

  local i=1
  while IFS= read -r line; do
    if [[ "$i" -eq "$lastLineNum" ]]; then
      # Handle inline case: class A { ... }
      if [[ "$line" =~ \{[^\}]*\} ]]; then
        local newLine="${line%\}} $code }"
        echo "$newLine"
      else
        if [[ "$newBlock" == true ]]; then
          echo ""
        fi
        printf "%s\n" "$code"
        echo "$line"
      fi
    else
      echo "$line"
    fi
    ((i++))
  done < "$file" > "${file}.injected"

  mv "${file}.injected" "$file"
}
