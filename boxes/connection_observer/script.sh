#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Specify path to a project root"
    exit 1
fi

projectPath="$1"

if [ ! -f "$projectPath/pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found in project root!"
    exit 1
fi

sourceDir="src/files"
destinationPath="$projectPath/core/lib/src/services"

if [ ! -d "$sourceDir" ]; then
    echo "Error: Source directory '$sourceDir' not found!"
    exit 1
fi

mkdir -p "$destinationPath"
cp -r "$sourceDir"/* "$destinationPath" && echo "Files copied to $destinationPath"

exportFileSource="src/export.dart"
exportFileDestination="$destinationPath/services.dart"

if [ -f "$exportFileSource" ]; then
    cat "$exportFileSource" >> "$exportFileDestination"
    dart format "$exportFileDestination" > /dev/null 2>&1
    echo "Added exports to $exportFileDestination"
fi

cd "$projectPath/core"
dart pub add observe_internet_connectivity
