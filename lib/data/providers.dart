import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase());
