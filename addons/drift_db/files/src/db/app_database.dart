import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../../../data.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[
  ExampleTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase.memory() : super(NativeDatabase.memory());

  AppDatabase() : super(driftDatabase(name: StorageConstants.appDatabaseName));

  @override
  int get schemaVersion => StorageConstants.appDatabaseVersion;
}
