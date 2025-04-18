#!/bin/bash

set -e

source "../shared/functions.sh"

projectRoot="$1"
ensure_valid_project_root "$projectRoot"

targetSrcDir="$projectRoot/data/lib/src"

copy_source_files \
  from="files/src" \
  to="$targetSrcDir/providers/shared/local"

append_exports \
  from="files/export.dart" \
  to="$targetSrcDir/providers/shared/shared.dart"

insert_code_into_method \
  file="$targetSrcDir/di/data_di.dart" \
  method="_initSharedProviders" \
  code="$(<files/di_code.dart)"

read -d '' constantsCode << EOF
  static const String appDatabaseName = 'appDatabase';
  static const int appDatabaseVersion = 1;
EOF

inject_member \
  file="$targetSrcDir/constants/storage_constants.dart" \
  code="$constantsCode" \
  --newBlock

add_dependency \
  project_dir="$projectRoot/data" \
  dependency="drift_flutter:^0.2.4"

add_dependency \
  project_dir="$projectRoot/data" \
  dependency="drift_dev:^2.23.1" \
  --dev

printf "Successfully added drift database to the project"