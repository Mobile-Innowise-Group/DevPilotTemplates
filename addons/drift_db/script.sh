#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Specify path to a project root"
    exit 1
fi

projectRoot="$1"

if [ ! -f "$projectRoot/pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found in project root!"
    exit 1
fi

targetSrcDir="$projectRoot/data/lib/src"

fromFilesDir="files/src"
toFilesDir="$targetSrcDir/providers/shared/local"
cp -r "$fromFilesDir"/* "$toFilesDir"

fromExportFile="files/export.dart"
toExportFile="$targetSrcDir/providers/shared/shared.dart"
sh "../shared_scripts/append_file_and_sort.sh" --from "$fromExportFile" --to "$toExportFile"

toDIFile="$targetSrcDir/di/data_di.dart"
diCode="locator.registerLazySingleton<AppDatabase>(AppDatabase.new);"

sh "../shared_scripts/append_di_to_file.sh" --file "$toDIFile" --method "_initSharedProviders" --code "$diCode"

cd "$projectPath/data"
dart pub add drift_flutter:^0.2.4
dart pub add drift_dev:^2.23.1 --dev
