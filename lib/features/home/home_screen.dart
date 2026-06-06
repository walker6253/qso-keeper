import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../services/update_checker.dart';
import '../../data/preferences/app_preferences.dart';
import '../../data/providers.dart';
import 'package:intl/intl.dart';

final datesProvider = FutureProvider<List<({int date, String label, int count, bool isToday})>>((ref) async {
  ref.watch(homeRefreshNotifier);
  final db = ref.watch(dbProvider);
  final items = await db.contactDao.getAllDatesWithCount();
  final today = DateTime.now();
  final todayEpoch = today.millisecondsSinceEpoch ~/ 86400000;
  return items.map((d) {
    final dt = DateTime.fromMillisecondsSinceEpoch(d.dateEpochDay * 86400000);
    String label;
    if (d.dateEpochDay == todayEpoch) label = '今天';
    else if (d.dateEpochDay == todayEpoch - 1) label = '昨天';
    else label = '${dt.year}年${dt.month}月${dt.day}日';
    return (date: d.dateEpochDay, label: label, count: d.count, isToday: d.dateEpochDay == todayEpoch);
  }).toList();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    await AppPreferences.init();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (AppPreferences.lastUpdateCheckDate != today) {
      final info = await UpdateChecker.check();
      AppPreferences.lastUpdateCheckDate = today;
      if (info.hasUpdate && mounted) {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(ctx).scaffoldBackgroundColor == AppColors.background ? AppColors.surface : Colors.white,
          title: Text('发现新版本 v${info.latestVersion}', style: TextStyle(color: AppColors.amber)),
          content: Text('当前版本: v${info.currentVersion}\n${info.body}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('关闭', style: TextStyle(color: AppColors.textMuted))),
          ],
        ));
      }
    }
  }

  Future<void> _pickDateAndGo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      locale: const Locale('zh'),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.dark(primary: AppColors.amber, onPrimary: AppColors.deep, surface: AppColors.surface),
      ), child: child!),
    );
    if (picked != null && mounted) {
      final epoch = picked.millisecondsSinceEpoch ~/ 86400000;
      context.go('/log/$epoch');
    }
  }

  @override
  Widget build(BuildContext context) {
    final datesAsync = ref.watch(datesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = isDark ? AppColors.surface : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF777680);
    final borderColor = isDark ? AppColors.border : const Color(0xFFE0E0E8);
    final amberColor = AppColors.amber;
    final amberBgColor = isDark ? AppColors.amber.withValues(alpha: 0.1) : AppColors.amber.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('QSO Keeper', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: amberColor, fontFamily: 'monospace')),
        actions: [IconButton(icon: Icon(Icons.bar_chart, color: amberColor), onPressed: () => context.go('/stats'))],
      ),
      body: datesAsync.when(
        data: (dates) => dates.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.radio, size: 64, color: textMuted.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('等待信号…', style: TextStyle(color: textMuted, fontSize: 14)),
              const SizedBox(height: 8),
              Text('点击右下角按钮开始记录', style: TextStyle(color: textMuted.withValues(alpha: 0.5), fontSize: 12)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: dates.length,
              itemBuilder: (ctx, i) {
                final d = dates[i];
                return Card(
                  color: surfaceColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: borderColor.withValues(alpha: 0.2))),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => context.go('/log/${d.date}'),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(children: [
                        if (d.isToday) ...[
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: amberColor, shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                        ],
                        Expanded(child: Text(d.label, style: TextStyle(
                          fontSize: 14, fontWeight: d.isToday ? FontWeight.w700 : FontWeight.w500,
                          color: d.isToday ? amberColor : textPrimary))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: amberBgColor, borderRadius: BorderRadius.circular(6)),
                          child: Text('${d.count} 条', style: TextStyle(fontSize: 11, color: amberColor, fontFamily: 'monospace'))),
                      ]),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (50 * i).ms).slideX(begin: 0.05, end: 0, duration: 300.ms, delay: (50 * i).ms);
              },
            ),
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.amber)),
        error: (e, _) => Center(child: Text('加载失败', style: TextStyle(color: AppColors.alertRed))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickDateAndGo,
        backgroundColor: AppColors.ionBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
