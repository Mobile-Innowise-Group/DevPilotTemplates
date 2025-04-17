#!/bin/bash

set -e

source "../shared/functions.sh"

projectRoot="$1"
ensure_valid_project_root "$projectRoot"

targetSrcDir="$projectRoot/core/lib/src"

copy_source_files \
  from="files/src" \
  to="$targetSrcDir/services"

append_exports \
  from="files/export.dart" \
  to="$targetSrcDir/services/services.dart"

add_dependency \
  project_dir="$projectRoot/core" \
  dependency="observe_internet_connectivity"

printf "Successfully added connectivity observer to the project"