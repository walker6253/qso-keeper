import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/charts.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';

// ==================== ???? & ?? ====================
enum Granularity { daily, weekly, monthly }
enum TrendRange { days7, days30, days90, days180, days365 }

extension GranularityLabel on Granularity {
  String get label {
    switch (this) {
      case Granularity.daily: return '\u6309\u5929';
      case Granularity.weekly: return '\u6309\u5468';
      case Granularity.monthly: return '\u6309\u6708';
    }
  }
}

extension TrendRangeLabel on TrendRange {
  String get label {
    switch (this) {
      case TrendRange.days7: return '7 \u5929';
      case TrendRange.days30: return '30 \u5929';
      case TrendRange.days90: return '90 \u5929';
      case TrendRange.days180: return '\u534a\u5e74';
      case TrendRange.days365: return '\u4e00\u5e74';
    }
  }
  int get days {
    switch (this) {
      case TrendRange.days7: return 7;
      case TrendRange.days30: return 30;
      case TrendRange.days90: return 90;
      case TrendRange.days180: return 180;
      case TrendRange.days365: return 365;
    }
  }
}

// ==================== ???? ====================
class _Layout {
  final double w;
  _Layout(this.w);
  bool get isExpanded => w >= 840;
  bool get isMedium => w >= 600 && w < 840;
  double get hPad => isExpanded ? 40.0 : (isMedium ? 24.0 : 16.0);
  int get overviewCols => isExpanded ? 6 : (isMedium ? 4 : 2);
  double get chartH => isMedium || isExpanded ? 200.0 : 140.0;
  double get scale => isExpanded ? 1.1 : (isMedium ? 1.05 : 1.0);
}

// ==================== ????? ====================
final statsDataProvider = FutureProvider<StatsData>((ref) async {
  final db = ref.watch(dbProvider);
  final contacts = await db.contactDao.getAllContacts();
  return StatsData.fromContacts(contacts);
});

class StatsData {
  final int total, distinctCalls, activeDays, bandsUsed, modesUsed;
  final double dailyAvg;
  final List<({String label, int count})> bands, modes;
  final List<({int hour, int count})> hours;
  final List<({String callsign, int count, String lastBand, String lastMode})> topCalls;
  final List<ContactRecord> allContacts;

  StatsData({
    required this.total, required this.distinctCalls, required this.activeDays,
    required this.bandsUsed, required this.modesUsed, required this.dailyAvg,
    required this.bands, required this.modes, required this.hours,
    required this.topCalls, required this.allContacts,
  });

  factory StatsData.fromContacts(List<ContactRecord> contacts) {
    final total = contacts.length;
    if (total == 0) {
      return StatsData(total: 0, distinctCalls: 0, activeDays: 0, bandsUsed: 0,
        modesUsed: 0, dailyAvg: 0, bands: [], modes: [],
        hours: List.generate(24, (i) => (hour: i, count: 0)), topCalls: [], allContacts: contacts);
    }
    final csSet = <String>{}, daysSet = <int>{};
    for (final c in contacts) {
      if (c.callsign.isNotEmpty) csSet.add(c.callsign.trim().toUpperCase());
      daysSet.add(c.dateEpochDay);
    }
    final bandCount = <String, int>{};
    for (final c in contacts) {
      final b = _getBand(c.frequencyMHz);
      bandCount[b.isEmpty ? '\u5176\u4ed6' : b] = (bandCount[b.isEmpty ? '\u5176\u4ed6' : b] ?? 0) + 1;
    }
    final bands = bandCount.entries.map((e) => (label: e.key, count: e.value)).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final modeCount = <String, int>{};
    for (final c in contacts) {
      final m = c.mode.isEmpty ? '\u5176\u4ed6' : c.mode;
      modeCount[m] = (modeCount[m] ?? 0) + 1;
    }
    final modes = modeCount.entries.map((e) => (label: e.key, count: e.value)).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final hourArr = List.generate(24, (_) => 0);
    for (final c in contacts) {
      hourArr[DateTime.fromMillisecondsSinceEpoch(c.createdAt).hour]++;
    }
    final hours = List.generate(24, (i) => (hour: i, count: hourArr[i]));
    final csCount = <String, int>{}, csLastBand = <String, String>{}, csLastMode = <String, String>{};
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
    final topCalls = csCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top10 = topCalls.take(10).map((e) => (
      callsign: e.key, count: e.value,
      lastBand: csLastBand[e.key] ?? '', lastMode: csLastMode[e.key] ?? '',
    )).toList();
    return StatsData(total: total, distinctCalls: csSet.length, activeDays: daysSet.length,
      bandsUsed: bands.length, modesUsed: modes.length,
      dailyAvg: daysSet.isNotEmpty ? total / daysSet.length : 0,
      bands: bands, modes: modes, hours: hours, topCalls: top10, allContacts: contacts);
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
  return '\u5176\u4ed6';
}

// ==================== ???? ====================
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  Granularity _granularity = Granularity.daily;
  TrendRange _range = TrendRange.days30;
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
    final surfaceVariant = isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceContainer;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.textLight;
    final textVariant = isDark ? AppColors.textDarkVariant : AppColors.textLightVariant;
    final textMuted = isDark ? AppColors.textMuted : AppColors.textLightMuted;
    final primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Consumer(builder: (_, ref, __) {
          ref.watch(homeRefreshNotifier);
          return Text('\u901a\u8054\u7edf\u8ba1', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18));
        }),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textPrimary), onPressed: () => context.go('/home')),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final layout = _Layout(constraints.maxWidth);
          return Center(
            child: SizedBox(
              width: layout.isExpanded ? 1080.0 : null,
              child: stats.when(
                data: (s) => s.total == 0
                  ? _emptyStats(textVariant, textMuted, layout)
                  : ListView(
                      padding: EdgeInsets.fromLTRB(layout.hPad, 12, layout.hPad, 40),
                      children: [
                        _overviewSection(s, surfaceVariant, textPrimary, textVariant, layout),
                        const SizedBox(height: 16),
                        _trendSection(s, surfaceVariant, textPrimary, textVariant, textMuted, primaryColor, layout),
                        const SizedBox(height: 16),
                        if (layout.isExpanded || layout.isMedium)
                          _bandModeRow(s, surfaceVariant, textPrimary, textVariant, textMuted, primaryColor, layout)
                        else ...[
                          _bandSection(s, surfaceVariant, textPrimary, textVariant, textMuted, primaryColor, layout),
                          const SizedBox(height: 16),
                          _modeSection(s, surfaceVariant, textPrimary, textVariant, textMuted, primaryColor, layout),
                        ],
                        const SizedBox(height: 16),
                        _hourSection(s, surfaceVariant, textPrimary, textVariant, textMuted, primaryColor, layout),
                        const SizedBox(height: 16),
                        _topCallsSection(s, surfaceVariant, textPrimary, textVariant, primaryColor, layout),
                      ],
                    ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(child: Text('\u52a0\u8f7d\u5931\u8d25', style: TextStyle(color: AppColors.alertRed))),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyStats(Color tv, Color tm, _Layout l) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.equalizer, size: 48, color: tm.withAlpha(102)),
      const SizedBox(height: 8),
      Text('\u6682\u65e0\u7edf\u8ba1\u6570\u636e', style: TextStyle(color: tv, fontSize: 14 * l.scale)),
      const SizedBox(height: 4),
      Text('\u8bb0\u5f55\u901a\u8054\u540e\u5373\u53ef\u67e5\u770b\u7edf\u8ba1\u56fe\u8868',
          style: TextStyle(color: tm.withAlpha(153), fontSize: 12 * l.scale)),
    ]),
  );

  // ==================== ?? ====================
  Widget _overviewSection(StatsData s, Color sv, Color tp, Color tv, _Layout l) {
    final items = <({String label, String value, IconData icon, Color color})>[
      (label: '\u603b\u901a\u8054', value: '${s.total}', icon: Icons.radio, color: colorForIndex(0)),
      (label: '\u72ec\u7acb\u547c\u53f7', value: '${s.distinctCalls}', icon: Icons.tag, color: colorForIndex(2)),
      (label: '\u6d3b\u8dc3\u5929\u6570', value: '${s.activeDays}', icon: Icons.calendar_month, color: colorForIndex(5)),
      (label: '\u6ce2\u6bb5\u6570', value: '${s.bandsUsed}', icon: Icons.show_chart, color: colorForIndex(3)),
      (label: '\u6a21\u5f0f\u6570', value: '${s.modesUsed}', icon: Icons.wifi_tethering, color: colorForIndex(4)),
      (label: '\u65e5\u5747', value: s.dailyAvg.toStringAsFixed(1), icon: Icons.access_time, color: colorForIndex(1)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [_dot(AppColors.primary), const SizedBox(width: 8),
        Text('\u603b\u89c8', style: TextStyle(fontSize: 14 * l.scale, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1))]),
      const SizedBox(height: 10),
      _overviewGrid(items, l.overviewCols, sv, tp, tv, l),
    ]);
  }

  Widget _overviewGrid(List<({String label, String value, IconData icon, Color color})> items, int cols, Color sv, Color tp, Color tv, _Layout l) {
    final rows = (items.length + cols - 1) ~/ cols;
    return Column(children: List.generate(rows, (row) => Padding(
      padding: EdgeInsets.only(bottom: row < rows - 1 ? 10 : 0),
      child: Row(children: List.generate(cols, (col) {
        final idx = row * cols + col;
        if (idx < items.length) {
          return Expanded(child: Padding(
            padding: EdgeInsets.only(left: col > 0 ? 10 : 0),
            child: _ovCard(items[idx], sv, tp, tv, l)));
        }
        return const Expanded(child: SizedBox.shrink());
      })),
    )));
  }

  Widget _ovCard(({String label, String value, IconData icon, Color color}) item, Color sv, Color tp, Color tv, _Layout l) {
    return Card(
      color: sv.withAlpha(114), elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 22, height: 22,
              decoration: BoxDecoration(color: item.color.withAlpha(45), borderRadius: BorderRadius.circular(6)),
              alignment: Alignment.center, child: Icon(item.icon, size: 13, color: item.color)),
            const SizedBox(width: 6),
            Text(item.label, style: TextStyle(fontSize: 10 * l.scale, color: tv), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
          const SizedBox(height: 4),
          Text(item.value, style: TextStyle(fontSize: 20 * l.scale, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: tp)),
        ])));
  }

  // ==================== ?? ====================
  Widget _trendSection(StatsData s, Color sv, Color tp, Color tv, Color tm, Color pc, _Layout l) {
    final trendData = _getTrend(s.allContacts);
    final peak = trendData.fold<int>(0, (m, p) => p.value > m ? p.value : m);
    return Card(color: sv.withAlpha(89), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_dot(pc), const SizedBox(width: 8),
            Text('\u901a\u8054\u8d8b\u52bf', style: TextStyle(fontSize: 14 * l.scale, fontWeight: FontWeight.w600, color: pc, letterSpacing: 1)),
            const Spacer(),
            if (peak > 0) Text('\u5cf0\u503c $peak', style: TextStyle(fontSize: 10 * l.scale, color: tv)),
          ]),
          const SizedBox(height: 10),
          _segChips<Granularity>(items: Granularity.values, selected: _granularity,
            label: (g) => g.label,
            onSelect: (g) => setState(() { _granularity = g; _cachedTrend = null; }),
            pc: pc, sc: sv, tv: tv),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6,
            children: TrendRange.values.map((r) {
              final sel = r == _range;
              return GestureDetector(
                onTap: () => setState(() { _range = r; _cachedTrend = null; }),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: sel ? pc : sv.withAlpha(127),
                    borderRadius: BorderRadius.circular(50),
                    border: sel ? null : Border.all(color: tm.withAlpha(76))),
                  child: Text(r.label, style: TextStyle(fontSize: 10 * l.scale,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    color: sel ? Colors.white : tv)),
                ));
            }).toList()),
          const SizedBox(height: 12),
          if (trendData.isEmpty) const _EmptyHint()
          else SizedBox(height: l.chartH,
            child: (_granularity == Granularity.daily && _range == TrendRange.days7)
              ? TrendBarChart(points: trendData, barColor: pc, axisColor: tm.withAlpha(76))
              : TrendLineChart(points: trendData, lineColor: pc, fillColor: pc.withAlpha(45), axisColor: tm.withAlpha(76))),
        ])));
  }

  // ==================== ??+???? ====================
  Widget _bandModeRow(StatsData s, Color sv, Color tp, Color tv, Color tm, Color pc, _Layout l) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 105, child: _bandSection(s, sv, tp, tv, tm, pc, l)),
      const SizedBox(width: 16),
      Expanded(flex: 95, child: _modeSection(s, sv, tp, tv, tm, pc, l)),
    ]);
  }

  Widget _bandSection(StatsData s, Color sv, Color tp, Color tv, Color tm, Color pc, _Layout l) {
    final wide = l.isExpanded || l.isMedium;
    return Card(color: sv.withAlpha(89), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_dot(pc), const SizedBox(width: 8),
            Text('\u6ce2\u6bb5\u5206\u5e03', style: TextStyle(fontSize: 14 * l.scale, fontWeight: FontWeight.w600, color: pc, letterSpacing: 1)),
            const Spacer(),
            Text('${s.bands.length} \u4e2a\u6ce2\u6bb5', style: TextStyle(fontSize: 10 * l.scale, color: tv)),
          ]),
          const SizedBox(height: 10),
          if (s.bands.isEmpty) const _EmptyHint()
          else if (wide)
            ..._bandWide(s, tp, tv, tm)
          else
            ..._bandNarrow(s, tp, tv, tm),
        ])));
  }

  List<Widget> _bandWide(StatsData s, Color tp, Color tv, Color tm) => [
    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(width: 16),
      SizedBox(width: 140, height: 140,
        child: DonutChart(items: s.bands, centerTitle: '\u603b\u901a\u8054', centerValue: '${s.total}',
          centerColor: tp, centerVariant: tv, trackColor: tm.withAlpha(51))),
      const SizedBox(width: 12),
      Expanded(child: HorizontalBarList(items: s.bands, total: s.total, textColor: tp, textVariant: tv, trackColor: tm.withAlpha(51))),
    ]),
  ];

  List<Widget> _bandNarrow(StatsData s, Color tp, Color tv, Color tm) => [
    SizedBox(height: 160,
      child: DonutChart(items: s.bands, centerTitle: '\u603b\u901a\u8054', centerValue: '${s.total}',
        centerColor: tp, centerVariant: tv, trackColor: tm.withAlpha(51))),
    const SizedBox(height: 8),
    HorizontalBarList(items: s.bands, total: s.total, textColor: tp, textVariant: tv, trackColor: tm.withAlpha(51)),
  ];

  Widget _modeSection(StatsData s, Color sv, Color tp, Color tv, Color tm, Color pc, _Layout l) {
    return Card(color: sv.withAlpha(89), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_dot(pc), const SizedBox(width: 8),
            Text('\u6a21\u5f0f\u5206\u5e03', style: TextStyle(fontSize: 14 * l.scale, fontWeight: FontWeight.w600, color: pc, letterSpacing: 1)),
            const Spacer(),
            Text('${s.modes.length} \u79cd\u6a21\u5f0f', style: TextStyle(fontSize: 10 * l.scale, color: tv)),
          ]),
          const SizedBox(height: 10),
          if (s.modes.isEmpty) const _EmptyHint()
          else HorizontalBarList(items: s.modes, total: s.total, textColor: tp, textVariant: tv, trackColor: tm.withAlpha(51)),
        ])));
  }

  Widget _hourSection(StatsData s, Color sv, Color tp, Color tv, Color tm, Color pc, _Layout l) {
    int ph = 0, pv = 0;
    for (final h in s.hours) { if (h.count > pv) { pv = h.count; ph = h.hour; } }
    return Card(color: sv.withAlpha(89), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_dot(pc), const SizedBox(width: 8),
            Text('\u6d3b\u8dc3\u65f6\u6bb5', style: TextStyle(fontSize: 14 * l.scale, fontWeight: FontWeight.w600, color: pc, letterSpacing: 1)),
            const Spacer(),
            if (pv > 0) Text('\u9ad8\u5cf0 $ph:00', style: TextStyle(fontSize: 10 * l.scale, color: tv)),
          ]),
          const SizedBox(height: 4),
          Text('\u5c0f\u65f6\u5206\u5e03\uff08\u57fa\u4e8e\u901a\u8054\u521b\u5efa\u65f6\u95f4\uff09', style: TextStyle(fontSize: 10 * l.scale, color: tm.withAlpha(153))),
          const SizedBox(height: 8),
          HourHeatStrip(hours: s.hours, baseColor: pc, textColor: tp, textVariant: tv, emptyColor: tm.withAlpha(38)),
        ])));
  }

  Widget _topCallsSection(StatsData s, Color sv, Color tp, Color tv, Color pc, _Layout l) {
    return Card(color: sv.withAlpha(89), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_dot(pc), const SizedBox(width: 8),
            Text('\u6d3b\u8dc3\u547c\u53f7 Top ${s.topCalls.length}',
                style: TextStyle(fontSize: 14 * l.scale, fontWeight: FontWeight.w600, color: pc, letterSpacing: 1)),
          ]),
          const SizedBox(height: 8),
          if (s.topCalls.isEmpty) const _EmptyHint()
          else ...s.topCalls.asMap().entries.map((e) {
            final rank = e.key + 1;
            final c = e.value;
            final maxCnt = s.topCalls.first.count;
            final pct = c.count / maxCnt;
            Color rc;
            if (rank == 1) { rc = const Color(0x3300BCD4); }
            else if (rank == 2) { rc = pc.withAlpha(38); }
            else if (rank == 3) { rc = const Color(0xFF4CAF50).withAlpha(45); }
            else { rc = sv.withAlpha(127); }
            return Padding(padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(width: 22, height: 22,
                  decoration: BoxDecoration(color: rc, borderRadius: BorderRadius.circular(4)),
                  alignment: Alignment.center,
                  child: Text('$rank', style: TextStyle(fontSize: 10 * l.scale, fontWeight: FontWeight.w600, color: tp))),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(c.callsign,
                      style: TextStyle(fontSize: 12 * l.scale, fontWeight: FontWeight.w600, fontFamily: 'monospace', color: tp),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${c.count} \u6b21', style: TextStyle(fontSize: 10 * l.scale, fontFamily: 'monospace', color: tv)),
                  ]),
                  const SizedBox(height: 3),
                  ClipRRect(borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(value: pct, minHeight: 4,
                      backgroundColor: tv.withAlpha(38),
                      valueColor: AlwaysStoppedAnimation(pc.withAlpha(178)))),
                  if (c.lastBand.isNotEmpty || c.lastMode.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(top: 3),
                      child: Row(children: [
                        if (c.lastBand.isNotEmpty) _tag(c.lastBand, sv, tv),
                        if (c.lastBand.isNotEmpty && c.lastMode.isNotEmpty) const SizedBox(width: 4),
                        if (c.lastMode.isNotEmpty) _tag(c.lastMode, sv, tv),
                      ])),
                ])),
              ]));
          }),
        ])));
  }

  List<({String key, String label, int value})> _buildTrend(List<ContactRecord> contacts) {
    if (contacts.isEmpty) return [];
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: _range.days));
    final cutoffMs = cutoff.millisecondsSinceEpoch;
    final filtered = contacts.where((c) => c.createdAt >= cutoffMs).toList();
    if (filtered.isEmpty) return [];
    switch (_granularity) {
      case Granularity.daily:
        final byDay = <DateTime, int>{};
        DateTime? firstDay, lastDay;
        for (final c in filtered) {
          final d = DateTime.fromMillisecondsSinceEpoch(c.createdAt);
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
          result.add((key: d.toIso8601String(), label: '${d.month}/${d.day}', value: cnt));
          d = d.add(const Duration(days: 1));
        }
        return result;
      case Granularity.weekly:
        final byWeek = <String, int>{};
        final labels = <String, String>{};
        for (final c in filtered) {
          final d = DateTime.fromMillisecondsSinceEpoch(c.createdAt);
          final jan1 = DateTime(d.year, 1, 1);
          final wn = ((d.difference(jan1).inDays + jan1.weekday - 1) / 7).floor() + 1;
          final key = '${d.year}-W${wn.toString().padLeft(2, '0')}';
          byWeek[key] = (byWeek[key] ?? 0) + 1;
          labels.putIfAbsent(key, () => '${d.month}/${d.day}');
        }
        return byWeek.entries.map((e) => (key: e.key, label: labels[e.key] ?? e.key, value: e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
      case Granularity.monthly:
        final byMonth = <String, int>{};
        final labels = <String, String>{};
        for (final c in filtered) {
          final d = DateTime.fromMillisecondsSinceEpoch(c.createdAt);
          final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
          byMonth[key] = (byMonth[key] ?? 0) + 1;
          labels.putIfAbsent(key, () => '${d.year}\u5e74${d.month}\u6708');
        }
        return byMonth.entries.map((e) => (key: e.key, label: labels[e.key] ?? e.key, value: e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    }
  }

  Widget _segChips<T>({required List<T> items, required T selected, required String Function(T) label,
    required void Function(T) onSelect, required Color pc, required Color sc, required Color tv}) {
    return Container(decoration: BoxDecoration(color: sc.withAlpha(153), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(2),
      child: Row(children: items.map((item) {
        final sel = item == selected;
        return Expanded(child: GestureDetector(onTap: () => onSelect(item),
          child: Container(padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: sel ? pc : Colors.transparent, borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: Text(label(item), style: TextStyle(fontSize: 10,
              fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? Colors.white : tv), maxLines: 1))));
      }).toList()));
  }

  Widget _dot(Color c) => Container(width: 6, height: 6, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)));
  Widget _tag(String t, Color sv, Color tv) => Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(color: sv.withAlpha(153), borderRadius: BorderRadius.circular(3)),
    child: Text(t, style: TextStyle(fontSize: 9, color: tv)));
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) => Container(height: 40,
    decoration: BoxDecoration(color: Colors.white.withAlpha(12), borderRadius: BorderRadius.circular(8)),
    alignment: Alignment.center,
    child: const Text('\u6682\u65e0\u6570\u636e', style: TextStyle(fontSize: 12, color: Colors.grey)));
}
