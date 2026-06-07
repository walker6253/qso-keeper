import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/charts.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';

// ==================== 数据粒度 & 范围 ====================
enum Granularity { daily, weekly, monthly }
enum TrendRange { days7, days30, days90, days180, days365 }

extension GranularityLabel on Granularity {
  String get label {
    switch (this) {
      case Granularity.daily:
        return '按天';
      case Granularity.weekly:
        return '按周';
      case Granularity.monthly:
        return '按月';
    }
  }
}

extension TrendRangeLabel on TrendRange {
  String get label {
    switch (this) {
      case TrendRange.days7:
        return '7 天';
      case TrendRange.days30:
        return '30 天';
      case TrendRange.days90:
        return '90 天';
      case TrendRange.days180:
        return '半年';
      case TrendRange.days365:
        return '一年';
    }
  }

  int get days {
    switch (this) {
      case TrendRange.days7:
        return 7;
      case TrendRange.days30:
        return 30;
      case TrendRange.days90:
        return 90;
      case TrendRange.days180:
        return 180;
      case TrendRange.days365:
        return 365;
    }
  }
}

// ==================== 数据提供器 ====================
final statsDataProvider = FutureProvider<StatsData>((ref) async {
  final db = ref.watch(dbProvider);
  final contacts = await db.contactDao.getAllContacts();
  return StatsData.fromContacts(contacts);
});

class StatsData {
  final int total;
  final int distinctCalls;
  final int activeDays;
  final int bandsUsed;
  final int modesUsed;
  final double dailyAvg;
  final List<({String label, int count})> bands;
  final List<({String label, int count})> modes;
  final List<({int hour, int count})> hours;
  final List<({String callsign, int count, String lastBand, String lastMode})> topCalls;
  final List<ContactRecord> allContacts;

  StatsData({
    required this.total,
    required this.distinctCalls,
    required this.activeDays,
    required this.bandsUsed,
    required this.modesUsed,
    required this.dailyAvg,
    required this.bands,
    required this.modes,
    required this.hours,
    required this.topCalls,
    required this.allContacts,
  });

  factory StatsData.fromContacts(List<ContactRecord> contacts) {
    final total = contacts.length;
    if (total == 0) {
      return StatsData(
        total: 0, distinctCalls: 0, activeDays: 0,
        bandsUsed: 0, modesUsed: 0, dailyAvg: 0,
        bands: [], modes: [], hours: List.generate(24, (i) => (hour: i, count: 0)),
        topCalls: [], allContacts: contacts,
      );
    }

    // 独立呼号
    final csSet = <String>{};
    final daysSet = <int>{};
    for (final c in contacts) {
      if (c.callsign.isNotEmpty) csSet.add(c.callsign.trim().toUpperCase());
      daysSet.add(c.dateEpochDay);
    }

    // 波段分布
    final bandCount = <String, int>{};
    for (final c in contacts) {
      final b = _getBand(c.frequencyMHz);
      final key = b.isEmpty ? '其他' : b;
      bandCount[key] = (bandCount[key] ?? 0) + 1;
    }
    final bands = bandCount.entries
        .map((e) => (label: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    // 模式分布
    final modeCount = <String, int>{};
    for (final c in contacts) {
      final m = c.mode.isEmpty ? '其他' : c.mode;
      modeCount[m] = (modeCount[m] ?? 0) + 1;
    }
    final modes = modeCount.entries
        .map((e) => (label: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    // 小时分布 (基于 createdAt)
    final hourArr = List.generate(24, (_) => 0);
    for (final c in contacts) {
      final dt = DateTime.fromMillisecondsSinceEpoch(c.createdAt);
      final h = dt.hour;
      hourArr[h]++;
    }
    final hours = List.generate(24, (i) => (hour: i, count: hourArr[i]));

    // Top 呼号
    final csCount = <String, int>{};
    final csLastBand = <String, String>{};
    final csLastMode = <String, String>{};
    final sortedByTime = List<ContactRecord>.from(contacts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final c in sortedByTime) {
      final key = c.callsign.trim().toUpperCase();
      if (key.isEmpty) continue;
      csCount[key] = (csCount[key] ?? 0) + 1;
      if (!csLastBand.containsKey(key)) {
        csLastBand[key] = _getBand(c.frequencyMHz);
        csLastMode[key] = c.mode;
      }
    }
    final topCalls = csCount.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top10 = topCalls.take(10).map((e) => (
          callsign: e.key,
          count: e.value,
          lastBand: csLastBand[e.key] ?? '',
          lastMode: csLastMode[e.key] ?? '',
        )).toList();

    return StatsData(
      total: total,
      distinctCalls: csSet.length,
      activeDays: daysSet.length,
      bandsUsed: bands.length,
      modesUsed: modes.length,
      dailyAvg: daysSet.length > 0 ? total / daysSet.length : 0,
      bands: bands,
      modes: modes,
      hours: hours,
      topCalls: top10,
      allContacts: contacts,
    );
  }
}

String _getBand(double mhz) {
  if (mhz >= 1.8 && mhz < 2.0) return '160m';
  if (mhz >= 3.5 && mhz < 4.0) return '80m';
  if (mhz >= 7.0 && mhz < 7.3) return '40m';
  if (mhz >= 10.0 && mhz < 10.2) return '30m';
  if (mhz >= 14.0 && mhz < 14.35) return '20m';
  if (mhz >= 18.0 && mhz < 19.0) return '17m';
  if (mhz >= 21.0 && mhz < 21.45) return '15m';
  if (mhz >= 24.0 && mhz < 25.0) return '12m';
  if (mhz >= 28.0 && mhz < 29.7) return '10m';
  if (mhz >= 50.0 && mhz < 54.0) return '6m';
  if (mhz >= 144.0 && mhz < 148.0) return '2m';
  if (mhz >= 430.0 && mhz < 450.0) return '70cm';
  return '其他';
}

// ==================== 统计页面 ====================
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  Granularity _granularity = Granularity.daily;
  TrendRange _range = TrendRange.days30;

  // 趋势数据缓存
  List<({String key, String label, int value})>? _cachedTrend;
  TrendRange? _cachedRange;
  Granularity? _cachedGranularity;

  List<({String key, String label, int value})> _getTrend(List<ContactRecord> contacts) {
    if (_cachedTrend != null && _cachedRange == _range && _cachedGranularity == _granularity) {
      return _cachedTrend!;
    }
    _cachedTrend = _buildTrend(contacts);
    _cachedRange = _range;
    _cachedGranularity = _granularity;
    return _cachedTrend!;
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceVariant =
        isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceContainer;
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.textLight;
    final textVariant =
        isDark ? AppColors.textDarkVariant : AppColors.textLightVariant;
    final textMuted =
        isDark ? AppColors.textMuted : AppColors.textLightMuted;
    final primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('通联统计',
            style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimary),
            onPressed: () => context.go('/home')),
      ),
      body: stats.when(
        data: (s) => s.total == 0
            ? Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Icon(Icons.equalizer,
                        size: 48,
                        color: textMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text('暂无统计数据',
                        style: TextStyle(color: textVariant, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('记录通联后即可查看统计图表',
                        style: TextStyle(
                            color: textMuted.withValues(alpha: 0.6),
                            fontSize: 12)),
                  ]))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                children: [
                  _overviewSection(s, surfaceVariant, textPrimary, textVariant),
                  const SizedBox(height: 16),
                  _trendSection(s, surfaceVariant, textPrimary, textVariant,
                      textMuted, primaryColor),
                  const SizedBox(height: 16),
                  _bandSection(s, surfaceVariant, textPrimary, textVariant,
                      textMuted, primaryColor),
                  const SizedBox(height: 16),
                  _modeSection(s, surfaceVariant, textPrimary, textVariant,
                      textMuted, primaryColor),
                  const SizedBox(height: 16),
                  _hourSection(s, surfaceVariant, textPrimary, textVariant,
                      textMuted, primaryColor),
                  const SizedBox(height: 16),
                  _topCallsSection(
                      s, surfaceVariant, textPrimary, textVariant, primaryColor),
                ],
              ),
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
            child: Text('加载失败',
                style: TextStyle(color: AppColors.alertRed))),
      ),
    );
  }

  // ==================== 总览 ====================
  Widget _overviewSection(StatsData s, Color surfaceVariant, Color textPrimary,
      Color textVariant) {
    final overviewItems = <({String label, String value, IconData icon, Color color})>[
      (label: '总通联', value: '${s.total}', icon: Icons.radio, color: colorForIndex(0)),
      (label: '独立呼号', value: '${s.distinctCalls}', icon: Icons.tag, color: colorForIndex(2)),
      (label: '活跃天数', value: '${s.activeDays}', icon: Icons.calendar_month, color: colorForIndex(5)),
      (label: '波段数', value: '${s.bandsUsed}', icon: Icons.show_chart, color: colorForIndex(3)),
      (label: '模式数', value: '${s.modesUsed}', icon: Icons.wifi_tethering, color: colorForIndex(4)),
      (label: '日均', value: s.dailyAvg.toStringAsFixed(1), icon: Icons.access_time, color: colorForIndex(1)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _sectionDot(AppColors.primary),
          const SizedBox(width: 8),
          Text('总览',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: overviewItems.map((item) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 42) / 2,
              child: _overviewCard(item, surfaceVariant, textPrimary,
                  textVariant),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _overviewCard(
      ({String label, String value, IconData icon, Color color}) item,
      Color surfaceVariant,
      Color textPrimary,
      Color textVariant) {
    return Card(
      color: surfaceVariant.withValues(alpha: 0.45),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6)),
                  alignment: Alignment.center,
                  child:
                      Icon(item.icon, size: 13, color: item.color)),
              const SizedBox(width: 6),
              Text(item.label,
                  style: TextStyle(
                      fontSize: 10, color: textVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
            const SizedBox(height: 4),
            Text(item.value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: textPrimary)),
          ],
        ),
      ),
    );
  }

  // ==================== 趋势 ====================
  Widget _trendSection(StatsData s, Color surfaceVariant, Color textPrimary,
      Color textVariant, Color textMuted, Color primaryColor) {
    final trendData = _getTrend(s.allContacts);
    final peak =
        trendData.fold<int>(0, (m, p) => p.value > m ? p.value : m);

    return Card(
      color: surfaceVariant.withValues(alpha: 0.35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(children: [
              _sectionDot(primaryColor),
              const SizedBox(width: 8),
              Text('通联趋势',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      letterSpacing: 1)),
              const Spacer(),
              if (peak > 0)
                Text('峰值 $peak',
                    style: TextStyle(fontSize: 10, color: textVariant)),
            ]),
            const SizedBox(height: 10),
            // 粒度选择
            _segmentedChips<Granularity>(
              items: Granularity.values,
              selected: _granularity,
              label: (g) => g.label,
              onSelect: (g) => setState(() { _granularity = g; _cachedTrend = null; }),
              primaryColor: primaryColor,
              surfaceColor: surfaceVariant,
              textVariant: textVariant,
            ),
            const SizedBox(height: 8),
            // 范围选择
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: TrendRange.values.map((r) {
                final sel = r == _range;
                return GestureDetector(
                  onTap: () => setState(() { _range = r; _cachedTrend = null; }),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: sel
                          ? primaryColor
                          : surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(50),
                      border: sel
                          ? null
                          : Border.all(
                              color: textMuted.withValues(alpha: 0.3),
                              width: 1),
                    ),
                    child: Text(r.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                            color: sel ? Colors.white : textVariant)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // 图表
            if (trendData.isEmpty)
              const _EmptySectionHint()
            else if (_granularity == Granularity.daily && _range == TrendRange.days7)
              TrendBarChart(
                points: trendData,
                barColor: primaryColor,
                axisColor: textMuted.withValues(alpha: 0.3),
              )
            else
              TrendLineChart(
                points: trendData,
                lineColor: primaryColor,
                fillColor: primaryColor.withValues(alpha: 0.18),
                axisColor: textMuted.withValues(alpha: 0.3),
              ),
          ]),
      ),
    );
  }

  List<({String key, String label, int value})> _buildTrend(
      List<ContactRecord> contacts) {
    if (contacts.isEmpty) return [];

    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: _range.days));
    final cutoffMs = cutoff.millisecondsSinceEpoch;
    final filtered =
        contacts.where((c) => c.createdAt >= cutoffMs).toList();
    if (filtered.isEmpty) return [];

    switch (_granularity) {
      case Granularity.daily:
        final byDay = <DateTime, int>{};
        DateTime? firstDay, lastDay;
        for (final c in filtered) {
          final d =
              DateTime.fromMillisecondsSinceEpoch(c.createdAt);
          final day = DateTime(d.year, d.month, d.day);
          byDay[day] = (byDay[day] ?? 0) + 1;
          if (firstDay == null || day.isBefore(firstDay)) firstDay = day;
          if (lastDay == null || day.isAfter(lastDay)) lastDay = day;
        }
        if (firstDay == null || lastDay == null) return [];
        final result = <({String key, String label, int value})>[];
        var d = firstDay;
        while (!d.isAfter(lastDay)) {
          final cnt = byDay[d] ?? 0;
          result.add((
            key: d.toIso8601String(),
            label: '${d.month}/${d.day}',
            value: cnt
          ));
          d = d.add(const Duration(days: 1));
        }
        return result;

      case Granularity.weekly:
        final byWeek = <String, int>{};
        final labels = <String, String>{};
        for (final c in filtered) {
          final d = DateTime.fromMillisecondsSinceEpoch(c.createdAt);
          // 简单按周分组：用年份+周数
          final jan1 = DateTime(d.year, 1, 1);
          final weekNum = ((d.difference(jan1).inDays + jan1.weekday - 1) / 7).floor() + 1;
          final key = '${d.year}-W${weekNum.toString().padLeft(2, '0')}';
          byWeek[key] = (byWeek[key] ?? 0) + 1;
          if (!labels.containsKey(key)) {
            labels[key] = '${d.month}/${d.day}';
          }
        }
        return byWeek.entries
            .map((e) =>
                (key: e.key, label: labels[e.key] ?? e.key, value: e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

      case Granularity.monthly:
        final byMonth = <String, int>{};
        final labels = <String, String>{};
        for (final c in filtered) {
          final d = DateTime.fromMillisecondsSinceEpoch(c.createdAt);
          final key =
              '${d.year}-${d.month.toString().padLeft(2, '0')}';
          byMonth[key] = (byMonth[key] ?? 0) + 1;
          if (!labels.containsKey(key)) {
            labels[key] = '${d.year}年${d.month}月';
          }
        }
        return byMonth.entries
            .map((e) =>
                (key: e.key, label: labels[e.key] ?? e.key, value: e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    }
  }

  Widget _segmentedChips<T>({
    required List<T> items,
    required T selected,
    required String Function(T) label,
    required void Function(T) onSelect,
    required Color primaryColor,
    required Color surfaceColor,
    required Color textVariant,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: surfaceColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: items.map((item) {
          final sel = item == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(item),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                    color: sel ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.center,
                child: Text(label(item),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.normal,
                        color: sel ? Colors.white : textVariant),
                    maxLines: 1),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== 波段分布 ====================
  Widget _bandSection(StatsData s, Color surfaceVariant, Color textPrimary,
      Color textVariant, Color textMuted, Color primaryColor) {
    return Card(
      color: surfaceVariant.withValues(alpha: 0.35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(children: [
              _sectionDot(primaryColor),
              const SizedBox(width: 8),
              Text('波段分布',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      letterSpacing: 1)),
              const Spacer(),
              Text('${s.bands.length} 个波段',
                  style: TextStyle(fontSize: 10, color: textVariant)),
            ]),
            const SizedBox(height: 10),
            if (s.bands.isEmpty)
              const _EmptySectionHint()
            else ..._bandContent(s, textPrimary, textVariant, textMuted),
          ]),
      ),
    );
  }

  List<Widget> _bandContent(StatsData s, Color textPrimary, Color textVariant, Color textMuted) {
    return [
      SizedBox(
          height: 160,
          child: DonutChart(
            items: s.bands,
            centerTitle: '总通联',
            centerValue: '${s.total}',
            centerColor: textPrimary,
            centerVariant: textVariant,
            trackColor: textMuted.withValues(alpha: 0.2),
          )),
      const SizedBox(height: 8),
      HorizontalBarList(
        items: s.bands,
        total: s.total,
        textColor: textPrimary,
        textVariant: textVariant,
        trackColor: textMuted.withValues(alpha: 0.2),
      ),
    ];
  }

  // ==================== 模式分布 ====================
  Widget _modeSection(StatsData s, Color surfaceVariant, Color textPrimary,
      Color textVariant, Color textMuted, Color primaryColor) {
    return Card(
      color: surfaceVariant.withValues(alpha: 0.35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(children: [
              _sectionDot(primaryColor),
              const SizedBox(width: 8),
              Text('模式分布',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      letterSpacing: 1)),
              const Spacer(),
              Text('${s.modes.length} 种模式',
                  style: TextStyle(fontSize: 10, color: textVariant)),
            ]),
            const SizedBox(height: 10),
            if (s.modes.isEmpty)
              const _EmptySectionHint()
            else
              HorizontalBarList(
                items: s.modes,
                total: s.total,
                textColor: textPrimary,
                textVariant: textVariant,
                trackColor: textMuted.withValues(alpha: 0.2),
              ),
          ]),
      ),
    );
  }

  // ==================== 活跃时段 ====================
  Widget _hourSection(StatsData s, Color surfaceVariant, Color textPrimary,
      Color textVariant, Color textMuted, Color primaryColor) {
    final peak = s.hours.fold<(int, int)?>(null, (prev, h) {
      if (prev == null || h.count > prev.$2) return (h.hour, h.count);
      return prev;
    });
    return Card(
      color: surfaceVariant.withValues(alpha: 0.35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(children: [
              _sectionDot(primaryColor),
              const SizedBox(width: 8),
              Text('活跃时段',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      letterSpacing: 1)),
              const Spacer(),
              if (peak != null && peak.$2 > 0)
                Text('高峰 ${peak.$1}:00',
                    style: TextStyle(fontSize: 10, color: textVariant)),
            ]),
            const SizedBox(height: 4),
            Text('小时分布（基于通联创建时间）',
                style: TextStyle(
                    fontSize: 10,
                    color: textMuted.withValues(alpha: 0.6))),
            const SizedBox(height: 8),
            HourHeatStrip(
              hours: s.hours,
              baseColor: primaryColor,
              textColor: textPrimary,
              textVariant: textVariant,
              emptyColor: textMuted.withValues(alpha: 0.15),
            ),
          ]),
      ),
    );
  }

  // ==================== 活跃呼号 Top 10 ====================
  Widget _topCallsSection(StatsData s, Color surfaceVariant, Color textPrimary,
      Color textVariant, Color primaryColor) {
    return Card(
      color: surfaceVariant.withValues(alpha: 0.35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(children: [
              _sectionDot(primaryColor),
              const SizedBox(width: 8),
              Text('活跃呼号 Top ${s.topCalls.length}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      letterSpacing: 1)),
            ]),
            const SizedBox(height: 8),
            if (s.topCalls.isEmpty)
              const _EmptySectionHint()
            else
              ...s.topCalls.asMap().entries.map((e) {
                final rank = e.key + 1;
                final c = e.value;
                final maxCnt = s.topCalls.first.count;
                final pct = c.count / maxCnt;
                final rankColor = rank == 1
                    ? const Color(0x3300BCD4)
                    : rank == 2
                        ? primaryColor.withValues(alpha: 0.15)
                        : rank == 3
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.18)
                            : surfaceVariant.withValues(alpha: 0.5);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: rankColor,
                              borderRadius: BorderRadius.circular(4)),
                          alignment: Alignment.center,
                          child: Text('$rank',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(children: [
                              Expanded(
                                child: Text(c.callsign,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'monospace',
                                        color: textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text('${c.count} 次',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: textVariant)),
                            ]),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 4,
                                backgroundColor:
                                    textVariant.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation(
                                    primaryColor.withValues(alpha: 0.7)),
                              ),
                            ),
                            if (c.lastBand.isNotEmpty ||
                                c.lastMode.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Row(children: [
                                  if (c.lastBand.isNotEmpty)
                                    _miniTag(c.lastBand, surfaceVariant,
                                        textVariant),
                                  if (c.lastBand.isNotEmpty &&
                                      c.lastMode.isNotEmpty)
                                    const SizedBox(width: 4),
                                  if (c.lastMode.isNotEmpty)
                                    _miniTag(c.lastMode, surfaceVariant,
                                        textVariant),
                                ]),
                              ),
                          ]),
                      ),
                    ]),
                );
              }),
          ]),
      ),
    );
  }

  Widget _miniTag(String text, Color surfaceVariant, Color textVariant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
          color: surfaceVariant.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(3)),
      child: Text(text,
          style: TextStyle(fontSize: 9, color: textVariant)),
    );
  }

  Widget _sectionDot(Color color) {
    return Container(
        width: 6, height: 6,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)));
  }
}

class _EmptySectionHint extends StatelessWidget {
  const _EmptySectionHint();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: const Text('暂无数据',
          style: TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}
