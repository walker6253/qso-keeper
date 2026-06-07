import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/responsive.dart';
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
    if (d.dateEpochDay == todayEpoch) {
      label = '\u4eca\u5929';
    } else if (d.dateEpochDay == todayEpoch - 1) {
      label = '\u6628\u5929';
    } else {
      label = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return (date: d.dateEpochDay, label: label, count: d.count, isToday: d.dateEpochDay == todayEpoch);
  }).toList();
});

String _fmt(String l, bool t) {
  if (t) return '\u4eca\u5929';
  if (l == '\u6628\u5929') return '\u6628\u5929';
  final p = l.split('-');
  if (p.length == 3) return '${p[0]}\u5e74${int.parse(p[1])}\u6708${int.parse(p[2])}\u65e5';
  return l;
}

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
          title: Text('\u53d1\u73b0\u65b0\u7248\u672c v${info.latestVersion}', style: TextStyle(color: AppColors.amber)),
          content: Text('\u5f53\u524d\u7248\u672c: v${info.currentVersion}\n${info.body}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('\u5173\u95ed', style: TextStyle(color: AppColors.textMuted))),
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
        colorScheme: Theme.of(ctx).brightness == Brightness.dark
          ? ColorScheme.dark(primary: AppColors.primary, surface: AppColors.darkSurface)
          : ColorScheme.light(primary: AppColors.primary, surface: AppColors.lightSurface),
        datePickerTheme: DatePickerThemeData(
          cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.grey)),
          confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.primary)),
        ),
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
    final accentColor = AppColors.amber;
    final accentBgColor = isDark ? AppColors.amber.withAlpha(25) : AppColors.amber.withAlpha(20);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Consumer(builder: (ctx, ref, _) {
          final callsign = AppPreferences.callsign;
          ref.watch(homeRefreshNotifier);
          final title = callsign.isNotEmpty ? '$callsign \u7684\u901a\u8054\u65e5\u5fd7' : '\u4e1a\u4f59\u65e0\u7ebf\u7535\u901a\u8054\u65e5\u5fd7';
          return Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: textPrimary, fontFamily: 'monospace'));
        }),
        actions: [IconButton(icon: Icon(Icons.bar_chart, color: textPrimary), onPressed: () => context.go('/stats'))],
      ),
      body: OrientationBuilder(
        builder: (ctx, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          final hPad = isLandscape ? 48.0 : responsiveHPadding(context);
          final useGrid = isLandscape || useTwoColumns(context);

          return datesAsync.when(
            data: (dates) => dates.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('\u6682\u65e0\u901a\u8054\u8bb0\u5f55', style: TextStyle(color: textMuted, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('\u70b9\u51fb\u53f3\u4e0b\u89d2\u6309\u94ae\u5f00\u59cb\u8bb0\u5f55', style: TextStyle(color: textMuted.withAlpha(127), fontSize: 13)),
                ]))
              : useGrid
                ? GridView.builder(
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 88),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: dates.length,
                    itemBuilder: (ctx, i) => _card(dates[i], i, surfaceColor, textPrimary, borderColor, accentColor, accentBgColor),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 88),
                    itemCount: dates.length,
                    itemBuilder: (ctx, i) => _card(dates[i], i, surfaceColor, textPrimary, borderColor, accentColor, accentBgColor),
                  ),
            loading: () => Center(child: CircularProgressIndicator(color: AppColors.amber)),
            error: (e, _) => Center(child: Text('\u52a0\u8f7d\u5931\u8d25', style: TextStyle(color: AppColors.alertRed))),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(shape: const CircleBorder(),
        onPressed: _pickDateAndGo,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _card(({int date, String label, int count, bool isToday}) d, int i, Color sc, Color tp, Color bc, Color ac, Color ab) {
    final dl = _fmt(d.label, d.isToday);
    return Card(
      color: sc,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: bc.withAlpha(51))),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go('/log/${d.date}'),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            if (d.isToday) ...[
              Container(width: 8, height: 8, decoration: BoxDecoration(color: tp, shape: BoxShape.circle)),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(dl, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: tp))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: ab, borderRadius: BorderRadius.circular(6)),
              child: Text('${d.count} \u6761', style: TextStyle(fontSize: 11, color: ac, fontFamily: 'monospace'))),
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * i).ms).slideX(begin: 0.05, end: 0, duration: 300.ms, delay: (50 * i).ms);
  }
}
