#!/bin/bash

flutter clean
flutter pub get
dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/src/localization/generated -S resources/lang