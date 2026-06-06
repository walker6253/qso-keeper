import 'package:drift/drift.dart';
import 'tables.dart';
import 'contact_dao.dart';
import 'daily_log_dao.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
part 'app_database.g.dart';

@DriftDatabase(tables: [ContactRecords, DailyLogs], daos: [ContactDao, DailyLogDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'hamlog.db'));
      return NativeDatabase(file);
    });
  }
}
