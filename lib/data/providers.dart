import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase());

final homeRefreshNotifier = StateProvider<int>((ref) => 0);
final persistedFreqProvider = StateProvider<String>((ref) => '');
final persistedModeProvider = StateProvider<String>((ref) => '');
final persistedBandProvider = StateProvider<String>((ref) => '');
