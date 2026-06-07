import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/contact_dao.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/database/tables.dart';

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(dbProvider);
  final total = await db.contactDao.getTotalCount();
  final distinctCalls = await db.contactDao.getDistinctCallsignCount();
  final activeDays = await db.contactDao.getActiveDaysCount();
  final modes = await db.contactDao.getModeDistribution();
  final first = await db.contactDao.getFirstContactDate();
  final last = await db.contactDao.getLastContactDate();
  final contacts = await db.contactDao.getAllContacts();
  final bands = <String, int>{};
  for (final c in contacts) {
    if (c.frequencyMHz > 0) {
      final b = _getBand(c.frequencyMHz);
      bands[b] = (bands[b] ?? 0) + 1;
    }
  }
  final topCalls = <String, int>{};
  for (final c in contacts) { topCalls[c.callsign] = (topCalls[c.callsign] ?? 0) + 1; }
  final sorted = topCalls.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  return {
    'total': total, 'distinctCalls': distinctCalls, 'activeDays': activeDays,
    'modes': modes, 'bands': bands, 'topCalls': sorted.take(10).toList(),
    'first': first, 'last': last,
  };
});

String _getBand(double mhz) {
  if (mhz >= 1.8 && mhz < 2.0) return '160m';
  if (mhz >= 3.5 && mhz < 4.0) return '80m';
  if (mhz >= 7.0 && mhz < 7.3) return '40m';
  if (mhz >= 10.0 && mhz < 10.2) return '30m';
  if (mhz >= 14.0 && mhz < 14.35) return '20m';
  if (mhz >= 21.0 && mhz < 21.45) return '15m';
  if (mhz >= 28.0 && mhz < 29.7) return '10m';
  if (mhz >= 50.0 && mhz < 54.0) return '6m';
  if (mhz >= 144.0 && mhz < 148.0) return '2m';
  if (mhz >= 430.0 && mhz < 450.0) return '70cm';
  return '其他';
}

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = isDark ? AppColors.surface : Colors.white;
    final surfaceLight = isDark ? AppColors.surfaceLight : const Color(0xFFF5F3F4);
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D);
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF434653);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF777680);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('通联统计', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textPrimary), onPressed: () => context.go('/home')),
      ),
      body: stats.when(
        data: (s) => s['total'] == 0
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bar_chart, size: 64, color: textMuted.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('暂无通联数据', style: TextStyle(color: textMuted, fontSize: 14)),
              Text('开始记录吧', style: TextStyle(color: textMuted.withValues(alpha: 0.5), fontSize: 12)),
            ]))
          : ListView(padding: const EdgeInsets.all(16), children: [
              Row(children: [
                Expanded(child: _statCard('总通联', '${s['total']}', surfaceColor, textPrimary, textMuted)),
                const SizedBox(width: 8), Expanded(child: _statCard('不同呼号', '${s['distinctCalls']}', surfaceColor, textPrimary, textMuted)),
                const SizedBox(width: 8), Expanded(child: _statCard('活跃天数', '${s['activeDays']}', surfaceColor, textPrimary, textMuted)),
              ]),
              const SizedBox(height: 16),
              _sectionTitle('模式分布'),
              const SizedBox(height: 8),
              ...((s['modes'] as List<ModeCount>).take(8).map((m) => Padding(padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(width: 70, child: Text(m.mode, style: TextStyle(color: textPrimary, fontSize: 12, fontFamily: 'monospace'))),
                  Expanded(child: Container(height: 16, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: surfaceLight),
                    child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: m.count / (s['total'] as int),
                      child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: AppColors.ionBlue))))),
                  const SizedBox(width: 8),
                  SizedBox(width: 40, child: Text('${(m.count / (s['total'] as int) * 100).toStringAsFixed(0)}%', style: TextStyle(color: textSecondary, fontSize: 11))),
                ])),
              )),
              const SizedBox(height: 16),
              _sectionTitle('活跃呼号 Top 10'),
              const SizedBox(height: 8),
              ...((s['topCalls'] as List<MapEntry<String, int>>).map((e) => Padding(padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  SizedBox(width: 80, child: Text(e.key, style: TextStyle(color: AppColors.amber, fontSize: 12, fontFamily: 'monospace'))),
                  Expanded(child: Container(height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: surfaceLight),
                    child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: e.value / (s['topCalls'] as List).first.value,
                      child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: AppColors.amber))))),
                  const SizedBox(width: 8),
                  Text('${e.value}', style: TextStyle(color: textSecondary, fontSize: 11)),
                ])),
              )),
              const SizedBox(height: 80),
            ]),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.amber)),
        error: (e, _) => Center(child: Text('加载失败', style: TextStyle(color: AppColors.alertRed))),
      ),
    );
  }

  Widget _statCard(String label, String value, Color surface, Color textPrimary, Color textMuted) =>
    Card(color: surface, elevation: 1, child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Column(children: [
      Text(value, style: TextStyle(color: AppColors.amber, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
      const SizedBox(height: 4), Text(label, style: TextStyle(color: textMuted, fontSize: 11)),
    ])));

  Widget _sectionTitle(String title) => Text(title, style: TextStyle(color: AppColors.amber, fontSize: 14, fontWeight: FontWeight.w700));
}
