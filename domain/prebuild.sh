#!/bin/zsh

echo "\033[1;36mRunning prebuild.sh in $(realpath "$0")\033[0m"

flutter clean
flutter pub get
