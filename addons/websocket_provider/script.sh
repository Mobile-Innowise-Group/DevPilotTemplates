#!/bin/bash

set -e

source "../shared/functions.sh"

projectRoot="$1"
ensure_valid_project_root "$projectRoot"

targetSrcDir="$projectRoot/data/lib/src"

copy_source_files \
  from="files/src" \
  to="$targetSrcDir/providers/shared/remote"

append_exports \
  from="files/export.dart" \
  to="$targetSrcDir/providers/shared/shared.dart"

insert_code_into_method \
  file="$targetSrcDir/di/data_di.dart" \
  method="_initSharedProviders" \
  code="$(<files/di_code.dart)"

add_dependency \
  project_dir="$projectRoot/data" \
  dependency="web_socket_channel"

printf "Successfully added Websocket provider to the project"