import 'package:drift/drift.dart';
import 'tables.dart';
import 'app_database.dart';
part 'daily_log_dao.g.dart';

@DriftAccessor(tables: [DailyLogs])
class DailyLogDao extends DatabaseAccessor<AppDatabase> with _$DailyLogDaoMixin {
  DailyLogDao(super.db);

  Future<DailyLogData?> getByDate(int dateEpochDay) =>
      (select(dailyLogs)..where((t) => t.dateEpochDay.equals(dateEpochDay))).getSingleOrNull();

  Future<int> insert(DailyLogsCompanion log) => into(dailyLogs).insertOnConflictUpdate(log);
}
