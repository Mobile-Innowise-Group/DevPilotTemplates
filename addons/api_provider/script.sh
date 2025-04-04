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
toFilesDir="$targetSrcDir/providers/shared/remote"
cp -r "$fromFilesDir"/* "$toFilesDir"

fromExportFile="files/export.dart"
toExportFile="$targetSrcDir/providers/shared/shared.dart"
sh "../shared_scripts/append_file_and_sort.sh" --from "$fromExportFile" --to "$toExportFile"

toDIFile="$targetSrcDir/di/data_di.dart"
read -d '' diCode << EOF
locator.registerLazySingleton<DioConfig>(
  () => DioConfig(
    appConfig: locator<AppConfig>(),
  ),
);

locator.registerLazySingleton<ErrorHandler>(
  () => ErrorHandler(
    eventNotifier: locator<AppEventNotifier>(),
  ),
);

locator.registerLazySingleton<ApiProvider>(
  () => ApiProvider(
    dio: locator<DioConfig>().dio,
    errorHandler: locator<ErrorHandler>(),
    listResultField: ApiConstants.listResponseField,
  ),
);
EOF

sh "../shared_scripts/append_di_to_file.sh" --file "$toDIFile" --method "_initSharedProviders" --code "$diCode"

