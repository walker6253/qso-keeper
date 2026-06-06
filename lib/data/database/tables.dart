import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

@DataClassName('ContactRecord')
class ContactRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dateEpochDay => integer()();
  TextColumn get callsign => text()();
  RealColumn get frequencyMHz => real()();
  TextColumn get mode => text()();
  TextColumn get rstSent => text()();
  TextColumn get rstReceived => text()();
  TextColumn get powerTx => text()();
  TextColumn get powerRx => text()();
  TextColumn get notes => text()();
  IntColumn get createdAt => integer()();
}

@DataClassName('DailyLogData')
class DailyLogs extends Table {
  IntColumn get dateEpochDay => integer()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get gridSquare => text()();
  TextColumn get address => text()();

  @override
  Set<Column> get primaryKey => {dateEpochDay};
}
