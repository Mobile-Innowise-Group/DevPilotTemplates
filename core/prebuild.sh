#!/bin/zsh

echo "\033[1;36mRunning prebuild.sh in $(realpath "$0")\033[0m"

flutter clean
flutter pub get
dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/src/localization/generated -S resources/lang