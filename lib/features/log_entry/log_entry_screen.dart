import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:url_launcher/url_launcher.dart' as ul;
import '../../core/design/app_colors.dart';
import '../../core/constants/band_constants.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables.dart';
import '../../data/providers.dart';
import '../../utils/smart_input_parser.dart';
import '../../utils/band_util.dart';
import '../../utils/callsign_utils.dart';

final logEntryProvider = FutureProvider.family<List<ContactRecord>, int>((ref, date) async {
  final db = ref.watch(dbProvider);
  return db.contactDao.getContactsByDate(date);
});

class LogEntryScreen extends ConsumerStatefulWidget {
  final int dateEpochDay;
  const LogEntryScreen({super.key, required this.dateEpochDay});
  @override
  ConsumerState<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends ConsumerState<LogEntryScreen> {
  final _smartInput = TextEditingController();
  final _mode = TextEditingController();
  final _rstSent = TextEditingController(text: '59');
  final _rstReceived = TextEditingController(text: '59');
  final _powerTx = TextEditingController(text: '100');
  final _powerRx = TextEditingController(text: '100');
  final _notes = TextEditingController();

  String _callsign = '', _frequency = '';
  String _preEditFreq = '', _preEditMode = '';
  bool _showRstSentKb = false, _showRstRecvKb = false, _showPowerTxKb = false, _showPowerRxKb = false;
  List<String> _suggestions = [];
  bool _showSuggestions = false, _showSuccess = false;
  String _band = '';
  bool _isCommitting = false;

  @override
  void dispose() {
    _smartInput.dispose(); _mode.dispose(); _rstSent.dispose(); _rstReceived.dispose();
    _powerTx.dispose(); _powerRx.dispose(); _notes.dispose();
    super.dispose();
  }

  void _onSmartInputChanged() {
    if (_isCommitting) return;
    final input = _smartInput.text;
    if (input.isEmpty) {
      setState(() { _frequency = _preEditFreq; _mode.text = _preEditMode; _callsign = ''; _showSuggestions = false; });
      return;
    }
    final prevEmpty = _smartInput.text.length <= 1 || (_smartInput.text.substring(0, _smartInput.text.length - 1).trim().isEmpty);
    if (prevEmpty) { _preEditFreq = _frequency; _preEditMode = _mode.text; }
    final parsed = SmartInputParser.parse(input);
    if (parsed.callsign.isNotEmpty) _callsign = parsed.callsign;
    if (parsed.frequencyMHz.isNotEmpty) { if (_frequency != parsed.frequencyMHz) { _frequency = parsed.frequencyMHz; _updateBand(); } }
    if (parsed.mode.isNotEmpty) _mode.text = parsed.mode;
    if (parsed.rstSent.isNotEmpty) _rstSent.text = parsed.rstSent;
    if (parsed.rstReceived.isNotEmpty) _rstReceived.text = parsed.rstReceived;
    if (parsed.powerTx.isNotEmpty) _powerTx.text = parsed.powerTx;
    if (parsed.powerRx.isNotEmpty) _powerRx.text = parsed.powerRx;
    if (parsed.notes.isNotEmpty) _notes.text = parsed.notes;
    if (parsed.callsign.isNotEmpty) {
      _searchCallsigns(parsed.callsign);
    } else {
      for (final token in input.trim().split(RegExp(r'\s+'))) {
        if (token.length >= 3 && RegExp(r'[A-Za-z].*[0-9]').hasMatch(token)) { _searchCallsigns(token); return; }
      }
      setState(() { _suggestions = []; _showSuggestions = false; });
    }
    setState(() {});
  }

  void _commitNext() {
    _isCommitting = true;
    _smartInput.clear();
    _isCommitting = false;
    FocusScope.of(context).unfocus();
    setState(() { _showRstSentKb = false; _showRstRecvKb = false; _showPowerTxKb = false; _showPowerRxKb = false; });
  }

  void _updateBand() {
    final mhz = double.tryParse(_frequency);
    if (mhz != null && mhz > 0) { _band = BandUtil.getBand(mhz); final m = BandUtil.autoMode(mhz); if (m.isNotEmpty && _mode.text.isEmpty) _mode.text = m; }
  }

  Future<void> _searchCallsigns(String q) async {
    if (q.length < 2) return;
    final db = ref.read(dbProvider); final s = await db.contactDao.searchCallsigns(q.toUpperCase().trim());
    if (mounted) setState(() { _suggestions = s; _showSuggestions = s.isNotEmpty; });
  }

  Future<void> _selectSuggestion(String callsign) async {
    _callsign = callsign; _showSuggestions = false; setState(() {});
    final db = ref.read(dbProvider); final last = await db.contactDao.getLastContactByCallsign(callsign);
    if (last != null && mounted) setState(() { _frequency = last.frequencyMHz > 0 ? last.frequencyMHz.toString() : ''; _mode.text = last.mode; _updateBand(); });
  }

  Future<void> _save() async {
    if (_callsign.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请先输入呼号'), backgroundColor: AppColors.alertRed)); return; }
    final db = ref.read(dbProvider);
    await db.contactDao.insertContact(ContactRecordsCompanion(
      dateEpochDay: Value(widget.dateEpochDay), callsign: Value(_callsign.toUpperCase()),
      frequencyMHz: Value(double.tryParse(_frequency) ?? 0), mode: Value(_mode.text.trim()),
      rstSent: Value(_rstSent.text.trim()), rstReceived: Value(_rstReceived.text.trim()),
      powerTx: Value(_powerTx.text.replaceAll(RegExp(r'[Ww]$'), '').trim()),
      powerRx: Value(_powerRx.text.replaceAll(RegExp(r'[Ww]$'), '').trim()),
      notes: Value(_notes.text.trim()), createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    _callsign = ''; _frequency = ''; _band = ''; _mode.clear(); _notes.clear(); _smartInput.clear();
    _rstSent.text = '59'; _rstReceived.text = '59'; _powerTx.text = '100'; _powerRx.text = '100';
    setState(() => _showSuccess = true);
    _closeAllKeyboards();
    ref.invalidate(logEntryProvider(widget.dateEpochDay));
    Future.delayed(Duration(seconds: 2), () { if (mounted) setState(() => _showSuccess = false); });
  }

  void _closeAllKeyboards() { setState(() { _showRstSentKb = false; _showRstRecvKb = false; _showPowerTxKb = false; _showPowerRxKb = false; }); FocusScope.of(context).unfocus(); }

  Future<void> _deleteContact(int id) async { await ref.read(dbProvider).contactDao.deleteContact(id); ref.invalidate(logEntryProvider(widget.dateEpochDay)); }

  Future<void> _editContact(ContactRecord c) async {
    final callsignCtrl = TextEditingController(text: c.callsign);
    final freqCtrl = TextEditingController(text: c.frequencyMHz > 0 ? c.frequencyMHz.toString() : '');
    final modeCtrl = TextEditingController(text: c.mode);
    final rsCtrl = TextEditingController(text: c.rstSent);
    final rrCtrl = TextEditingController(text: c.rstReceived);
    final ptxCtrl = TextEditingController(text: c.powerTx);
    final prxCtrl = TextEditingController(text: c.powerRx);
    final notesCtrl = TextEditingController(text: c.notes);
    final dateLabel = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(c.dateEpochDay * 86400000));
    final timeLabel = DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(c.createdAt));
    var editDateEpoch = c.dateEpochDay;
    var editCreatedAt = c.createdAt;
    var modeExpanded = false;
    final modeOptions = ['USB', 'LSB', 'FM'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : Colors.white;
    final inputBg = isDark ? AppColors.surfaceLight : const Color(0xFFF5F3F4);

    final result = await showDialog<bool>(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('编辑通联', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D))),
          Text('QSO Editor', style: TextStyle(fontSize: 11, letterSpacing: 2, color: AppColors.textMuted)),
        ]),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Date + Time row
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('日期', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              TextField(controller: TextEditingController(text: dateLabel), readOnly: true, enabled: false,
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D)),
                decoration: _editInputDeco(inputBg, isDark),
                onTap: () async {
                  final picked = await showDatePicker(context: ctx, initialDate: DateTime.fromMillisecondsSinceEpoch(editDateEpoch * 86400000),
                    firstDate: DateTime(2000), lastDate: DateTime.now(),
                    builder: (_, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: AppColors.amber)), child: child!));
                  if (picked != null) { setDlg(() => editDateEpoch = picked.millisecondsSinceEpoch ~/ 86400000); }
                }),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('时间', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              TextField(controller: TextEditingController(text: timeLabel), readOnly: true, enabled: false,
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D)),
                decoration: _editInputDeco(inputBg, isDark),
                onTap: () async {
                  final t = TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(editCreatedAt));
                  final picked = await showTimePicker(context: ctx, initialTime: t,
                    builder: (_, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: AppColors.amber)), child: child!));
                  if (picked != null) {
                    final dt = DateTime.fromMillisecondsSinceEpoch(editDateEpoch * 86400000);
                    setDlg(() => editCreatedAt = DateTime(dt.year, dt.month, dt.day, picked.hour, picked.minute).millisecondsSinceEpoch);
                  }
                }),
            ])),
          ]),
          const SizedBox(height: 14),
          // Callsign
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('呼号', style: _editLabelStyle(isDark)),
            const SizedBox(height: 4),
            TextField(controller: callsignCtrl,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.amber : const Color(0xFF7A5C00)),
              textCapitalization: TextCapitalization.characters,
              decoration: _editInputDeco(inputBg, isDark)),
          ]),
          const SizedBox(height: 14),
          // Freq + Mode
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('频率 MHz', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              TextField(controller: freqCtrl, style: _editFieldStyle(isDark), decoration: _editInputDeco(inputBg, isDark)),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('模式', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              _buildModeDropdown(ctx, modeCtrl, modeOptions, modeExpanded, (v) => setDlg(() => modeExpanded = v), inputBg, isDark),
            ])),
          ]),
          const SizedBox(height: 14),
          // RST
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('RST 发送', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              TextField(controller: rsCtrl, style: _editFieldStyle(isDark), decoration: _editInputDeco(inputBg, isDark)),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('RST 接收', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              TextField(controller: rrCtrl, style: _editFieldStyle(isDark), decoration: _editInputDeco(inputBg, isDark)),
            ])),
          ]),
          const SizedBox(height: 14),
          // Power
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('功率 发送', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              TextField(controller: ptxCtrl, style: _editFieldStyle(isDark), decoration: _editInputDeco(inputBg, isDark)),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('功率 接收', style: _editLabelStyle(isDark)),
              const SizedBox(height: 4),
              TextField(controller: prxCtrl, style: _editFieldStyle(isDark), decoration: _editInputDeco(inputBg, isDark)),
            ])),
          ]),
          const SizedBox(height: 14),
          // Notes
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('备注', style: _editLabelStyle(isDark)),
            const SizedBox(height: 4),
            TextField(controller: notesCtrl, maxLines: 3, style: _editFieldStyle(isDark), decoration: _editInputDeco(inputBg, isDark)),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消', style: TextStyle(color: isDark ? AppColors.textMuted : const Color(0xFF777680)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: Text('保存', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.amber))),
        ],
      ));
    });
    if (result == true) {
      final db = ref.read(dbProvider);
      await db.contactDao.updateContact(ContactRecord(
        id: c.id, dateEpochDay: editDateEpoch, callsign: callsignCtrl.text.trim().toUpperCase(),
        frequencyMHz: double.tryParse(freqCtrl.text) ?? c.frequencyMHz, mode: modeCtrl.text.trim(),
        rstSent: rsCtrl.text.trim(), rstReceived: rrCtrl.text.trim(),
        powerTx: ptxCtrl.text.trim(), powerRx: prxCtrl.text.trim(),
        notes: notesCtrl.text.trim(), createdAt: editCreatedAt,
      ));
      ref.invalidate(logEntryProvider(widget.dateEpochDay));
    }
  }

  InputDecoration _editInputDeco(Color bg, bool isDark) => InputDecoration(
    filled: true, fillColor: bg, isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.border.withValues(alpha: 0.3) : const Color(0xFFC3C6D5))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.border.withValues(alpha: 0.3) : const Color(0xFFC3C6D5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
  );

  TextStyle _editLabelStyle(bool isDark) => TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: isDark ? AppColors.amber : const Color(0xFF7A5C00));

  TextStyle _editFieldStyle(bool isDark) => TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D));

  Widget _buildModeDropdown(BuildContext ctx, TextEditingController ctrl, List<String> options, bool expanded, Function(bool) onExpand, Color bg, bool isDark) {
    final val = ctrl.text.isNotEmpty ? ctrl.text : options.first;
    return GestureDetector(
      onTap: () => onExpand(!expanded),
      child: Container(
        height: 40, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? AppColors.border.withValues(alpha: 0.3) : const Color(0xFFC3C6D5))),
        child: Row(children: [
          Expanded(child: Text(val, style: _editFieldStyle(isDark))),
          Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: isDark ? AppColors.textMuted : const Color(0xFF777680)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(logEntryProvider(widget.dateEpochDay));
    final dt = DateTime.fromMillisecondsSinceEpoch(widget.dateEpochDay * 86400000);
    final today = DateTime.now();
    final todayEpoch = today.millisecondsSinceEpoch ~/ 86400000;
    final dateLabel = '${dt.year}年${dt.month}月${dt.day}日';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = isDark ? AppColors.surface : Colors.white;
    final surfaceLightColor = isDark ? AppColors.surfaceLight : const Color(0xFFF5F3F4);
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D);
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF434653);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF777680);
    final borderColor = isDark ? AppColors.border : const Color(0xFFE0E0E8);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D)), onPressed: () => context.go('/home')),
        title: Text(dateLabel, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.amber : const Color(0xFF7A5C00))),
        backgroundColor: bgColor, elevation: 0,
      ),
      body: Stack(children: [
        SingleChildScrollView(padding: EdgeInsets.fromLTRB(14, 10, 14, 100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_showSuccess)
            Container(width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: AppColors.scopeGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check, color: AppColors.scopeGreen, size: 18), SizedBox(width: 8),
                Text('保存成功', style: TextStyle(color: AppColors.scopeGreen, fontSize: 13, fontWeight: FontWeight.w600)),
              ])).animate().fadeIn(duration: 300.ms).slideY(begin: -0.5, end: 0, duration: 300.ms),

          // Freq | Mode | Band info panel
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor.withValues(alpha: 0.3))),
            child: Row(children: [
              Expanded(child: _infoPanel('频率', _frequency.isNotEmpty ? _frequency : '--', textPrimary)),
              Container(width: 1, height: 32, color: borderColor.withValues(alpha: 0.3)),
              Expanded(child: _infoPanel('模式', _mode.text.isNotEmpty ? _mode.text : '--', textPrimary)),
              Container(width: 1, height: 32, color: borderColor.withValues(alpha: 0.3)),
              Expanded(child: _infoPanel('波段', _band.isNotEmpty ? _band : '--', textPrimary)),
            ]),
          ),

          // Smart input
          TextField(
            controller: _smartInput,
            style: TextStyle(fontSize: 14, fontFamily: 'monospace', color: textPrimary),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onChanged: (_) { _onSmartInputChanged(); setState(() {}); },
            onSubmitted: (_) => _commitNext(),
            decoration: InputDecoration(
              hintText: '呼号 频率 模式...',
              hintStyle: TextStyle(color: textMuted, fontSize: 13),
              filled: true, fillColor: isDark ? AppColors.surface : const Color(0xFFF5F3F4),
              suffixIcon: _smartInput.text.isNotEmpty
                ? IconButton(icon: Icon(Icons.keyboard_return, size: 20, color: isDark ? AppColors.amber : const Color(0xFF7A5C00)), onPressed: _commitNext)
                : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
            ),
          ),

          // Parsed callsign
          if (_callsign.isNotEmpty) Padding(padding: EdgeInsets.only(top: 6, bottom: 4), child: Row(children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.amber.withValues(alpha: 0.25))),
              child: Text(_callsign, style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'monospace'))),
            SizedBox(width: 8),
            Builder(builder: (_) { final prov = CallSignUtils.getProvince(_callsign); return prov != null ? Text(prov, style: TextStyle(color: textMuted, fontSize: 11)) : SizedBox.shrink(); }),
          ])),

          // Suggestions
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(margin: EdgeInsets.only(top: 2), decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor.withValues(alpha: 0.3))),
              child: Column(children: _suggestions.map((s) => InkWell(onTap: () => _selectSuggestion(s), child: Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Text(s, style: TextStyle(color: AppColors.amber, fontSize: 13, fontFamily: 'monospace'))))).toList())),

          SizedBox(height: 14),

          // RST
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _rstColumn('我的信号报告', _rstSent, _showRstSentKb, () => setState(() { _showRstSentKb = !_showRstSentKb; _showRstRecvKb = false; _showPowerTxKb = false; _showPowerRxKb = false; }), (v) { _rstSent.text = v; setState(() => _showRstSentKb = false); }, surfaceLightColor, borderColor, textPrimary, textSecondary)),
            SizedBox(width: 12),
            Expanded(child: _rstColumn('对方信号报告', _rstReceived, _showRstRecvKb, () => setState(() { _showRstRecvKb = !_showRstRecvKb; _showRstSentKb = false; _showPowerTxKb = false; _showPowerRxKb = false; }), (v) { _rstReceived.text = v; setState(() => _showRstRecvKb = false); }, surfaceLightColor, borderColor, textPrimary, textSecondary)),
          ]), SizedBox(height: 14),

          // Power
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _powerColumn('我的功率 (W)', _powerTx, _showPowerTxKb, () => setState(() { _showPowerTxKb = !_showPowerTxKb; _showRstSentKb = false; _showRstRecvKb = false; _showPowerRxKb = false; }), (v) { _powerTx.text = v; setState(() => _showPowerTxKb = false); }, surfaceLightColor, borderColor, textPrimary, textSecondary)),
            SizedBox(width: 12),
            Expanded(child: _powerColumn('对方功率 (W)', _powerRx, _showPowerRxKb, () => setState(() { _showPowerRxKb = !_showPowerRxKb; _showRstSentKb = false; _showRstRecvKb = false; _showPowerTxKb = false; }), (v) { _powerRx.text = v; setState(() => _showPowerRxKb = false); }, surfaceLightColor, borderColor, textPrimary, textSecondary)),
          ]), SizedBox(height: 14),

          // Notes
          TextField(controller: _notes, maxLines: 2, style: TextStyle(fontSize: 13, color: textPrimary),
            decoration: InputDecoration(
              labelText: '备注', labelStyle: TextStyle(color: textSecondary),
              filled: true, fillColor: isDark ? AppColors.surface : const Color(0xFFF5F3F4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
            )),
          SizedBox(height: 14),

          // Save button
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _callsign.isNotEmpty ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber, foregroundColor: AppColors.deep,
              padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              disabledBackgroundColor: AppColors.amber.withValues(alpha: 0.35),
            ),
            child: Text('保存通联', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)))),
          SizedBox(height: 20),

          // Contact list header
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            Text(widget.dateEpochDay == todayEpoch ? '今日通联' : '${dt.month}月${dt.day}日 通联',
              style: TextStyle(color: AppColors.amber, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
            if (widget.dateEpochDay == todayEpoch) ...[
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text('${contactsAsync.valueOrNull?.length ?? 0} 条', style: TextStyle(fontSize: 11, color: AppColors.amber, fontFamily: 'monospace'))),
            ],
          ])),
          contactsAsync.when(
            data: (contacts) => contacts.isEmpty
              ? Center(child: Padding(padding: EdgeInsets.all(32), child: Text('暂无记录', style: TextStyle(color: textMuted))))
              : Column(children: contacts.map((c) => _contactCard(c, surfaceColor, borderColor, textPrimary, textSecondary, textMuted)).toList()),
            loading: () => Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.amber))),
            error: (e, _) => Center(child: Text('加载失败', style: TextStyle(color: AppColors.alertRed))),
          ),
        ])),
      ]),
    );
  }

  Widget _infoPanel(String label, String value, Color textPrimary) => Column(children: [
    Text(label.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.2)),
    const SizedBox(height: 3),
    Text(value, style: TextStyle(color: AppColors.amber, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
  ]);

  Widget _rstColumn(String label, TextEditingController ctrl, bool showKb, VoidCallback onTap, Function(String) onSelect,
    Color surfaceLight, Color border, Color textPrimary, Color textSecondary) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _secLabel(label, textSecondary),
      GestureDetector(onTap: onTap, child: Container(width: double.infinity, height: 36, alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: surfaceLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: border.withValues(alpha: 0.3))),
        child: Text(ctrl.text, style: TextStyle(fontSize: 13, color: textPrimary)))),
      if (showKb) _rstKeyboard(ctrl, surfaceLight, border, textPrimary),
      SizedBox(height: 6),
      _quickChipRow(['59', '58', '57', '56'], ctrl.text, onSelect, const Color(0xFF01D00D), const Color(0xFFF9A825), surfaceLight, border, textSecondary),
    ]);

  Widget _powerColumn(String label, TextEditingController ctrl, bool showKb, VoidCallback onTap, Function(String) onSelect,
    Color surfaceLight, Color border, Color textPrimary, Color textSecondary) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _secLabel(label, textSecondary),
      GestureDetector(onTap: onTap, child: Container(width: double.infinity, height: 36, alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: surfaceLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: border.withValues(alpha: 0.3))),
        child: Text(ctrl.text, style: TextStyle(fontSize: 13, color: textPrimary)))),
      if (showKb) _powerKeyboard(ctrl, surfaceLight, border, textPrimary),
      SizedBox(height: 6),
      _quickChipRow(['5', '10', '50', '100'], ctrl.text, onSelect, const Color(0xFF01D00D), const Color(0xFFC62828), surfaceLight, border, textSecondary),
    ]);

  Widget _secLabel(String t, Color c) => Padding(padding: EdgeInsets.only(left: 2, bottom: 4), child: Text(t.toUpperCase(), style: TextStyle(color: c, fontSize: 10, letterSpacing: 1)));

  Widget _rstKeyboard(TextEditingController ctrl, Color surfaceLight, Color border, Color textPrimary) =>
    Padding(padding: EdgeInsets.only(top: 4), child: Container(width: double.infinity, padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: surfaceLight, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Row(children: [1,2,3,4,5].map((d) => Expanded(child: _kbtn('$d', ctrl, 2, surfaceLight, border, textPrimary))).toList()), SizedBox(height: 4),
        Row(children: [6,7,8,9,0].map((d) => Expanded(child: _kbtn('$d', ctrl, 2, surfaceLight, border, textPrimary))).toList()), SizedBox(height: 4),
        Row(children: [
          Expanded(child: _abtn('清空', () => ctrl.clear(), AppColors.alertRed)), SizedBox(width: 4),
          Expanded(child: _abtn('删除', () { if (ctrl.text.isNotEmpty) ctrl.text = ctrl.text.substring(0, ctrl.text.length - 1); }, AppColors.textSecondary)), SizedBox(width: 4),
          Expanded(child: _abtn('完成', () => setState(() { _showRstSentKb = false; _showRstRecvKb = false; }), AppColors.scopeGreen)),
        ]),
      ])));

  Widget _powerKeyboard(TextEditingController ctrl, Color surfaceLight, Color border, Color textPrimary) =>
    Padding(padding: EdgeInsets.only(top: 4), child: Container(width: double.infinity, padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: surfaceLight, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Row(children: ['1','2','3'].map((d) => Expanded(child: _kbtn(d, ctrl, 4, surfaceLight, border, textPrimary))).toList()), SizedBox(height: 4),
        Row(children: ['4','5','6'].map((d) => Expanded(child: _kbtn(d, ctrl, 4, surfaceLight, border, textPrimary))).toList()), SizedBox(height: 4),
        Row(children: ['7','8','9'].map((d) => Expanded(child: _kbtn(d, ctrl, 4, surfaceLight, border, textPrimary))).toList()), SizedBox(height: 4),
        Row(children: [
          Expanded(child: _kbtn('0', ctrl, 4, surfaceLight, border, textPrimary)), SizedBox(width: 4),
          Expanded(child: _abtn('清空', () => ctrl.clear(), AppColors.alertRed)), SizedBox(width: 4),
          Expanded(child: _abtn('删除', () { if (ctrl.text.isNotEmpty) ctrl.text = ctrl.text.substring(0, ctrl.text.length - 1); }, AppColors.textSecondary)), SizedBox(width: 4),
          Expanded(child: _abtn('完成', () => setState(() { _showPowerTxKb = false; _showPowerRxKb = false; }), AppColors.ionBlue)),
        ]),
      ])));

  Widget _kbtn(String d, TextEditingController c, int m, Color surface, Color border, Color textPrimary) => GestureDetector(
    onTap: () { if (c.text.length < m) c.text += d; },
    child: Container(height: 34, alignment: Alignment.center, margin: EdgeInsets.all(1),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: border.withValues(alpha: 0.3))),
      child: Text(d, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: textPrimary))));

  Widget _abtn(String l, VoidCallback t, Color cl) => GestureDetector(onTap: t,
    child: Container(height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: cl.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: cl.withValues(alpha: 0.3))),
      child: Text(l, style: TextStyle(color: cl, fontSize: 11, fontWeight: FontWeight.w600))));

  Widget _quickChipRow(List<String> items, String selected, Function(String) onSelect, Color from, Color to,
    Color surfaceLight, Color border, Color textSecondary) {
    return Row(children: items.asMap().entries.map((e) {
      final sel = e.value == selected;
      final t = (items.length > 1) ? e.key / (items.length - 1) : 0.0;
      final chipColor = Color.lerp(from, to, t)!;
      return Expanded(child: GestureDetector(onTap: () => onSelect(e.value), child: Container(
        height: 28, margin: EdgeInsets.symmetric(horizontal: 2), alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? chipColor.withValues(alpha: 0.25) : surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? chipColor : border.withValues(alpha: 0.15))),
        child: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, fontFamily: 'monospace', color: sel ? chipColor : textSecondary)))));
    }).toList());
  }

  Widget _contactCard(ContactRecord c, Color surface, Color border, Color textPrimary, Color textSecondary, Color textMuted) {
    final accent = BandConstants.modeColor(c.mode);
    final timeStr = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(c.createdAt));

    return Dismissible(
      key: Key('c_${c.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (dir) async { _deleteContact(c.id); return false; },
      background: Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(color: AppColors.alertRed.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.delete, color: AppColors.alertRed)),
      secondaryBackground: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.alertRed.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.delete, color: AppColors.alertRed)),
      child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Material(
        color: surface, borderRadius: BorderRadius.circular(10), elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: InkWell(borderRadius: BorderRadius.circular(10), onTap: () => _editContact(c),
          child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Left accent bar
            Container(width: 4, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.horizontal(left: Radius.circular(10))), constraints: const BoxConstraints(minHeight: 72)),
            Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              // Row 1: Callsign + QRZ | Time + Mode badge
              Row(children: [
                Expanded(child: Row(children: [
                  Text(c.callsign, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.5, color: textPrimary)),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () => _openQrz(c.callsign), child: Text('QRZ', style: TextStyle(color: textMuted, fontSize: 10))),
                ])),
                Row(children: [
                  Icon(Icons.access_time, size: 11, color: textMuted), const SizedBox(width: 3),
                  Text(timeStr, style: TextStyle(color: textMuted, fontSize: 11)),
                  const SizedBox(width: 6),
                  _modePill(c.mode, accent),
                ]),
              ]),
              // Row 2: Frequency + RST
              if (c.frequencyMHz > 0 || c.rstSent.isNotEmpty || c.rstReceived.isNotEmpty) ...[
                const SizedBox(height: 5),
                Row(children: [
                  if (c.frequencyMHz > 0) Text('${c.frequencyMHz} MHz', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'monospace', color: textPrimary)),
                  const Spacer(),
                  if (c.rstSent.isNotEmpty) ...[
                    Text('Snt ', style: TextStyle(color: textSecondary, fontSize: 11)),
                    Text(c.rstSent, style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                  if (c.rstSent.isNotEmpty && c.rstReceived.isNotEmpty) Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('|', style: TextStyle(color: textMuted, fontSize: 11))),
                  if (c.rstReceived.isNotEmpty) ...[
                    Text('Rcv ', style: TextStyle(color: textSecondary, fontSize: 11)),
                    Text(c.rstReceived, style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                  if ((c.rstSent.isNotEmpty || c.rstReceived.isNotEmpty) && c.powerTx.isNotEmpty) Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('|', style: TextStyle(color: textMuted, fontSize: 11))),
                  if (c.powerTx.isNotEmpty) ...[
                    Text('Txp ', style: TextStyle(color: textSecondary, fontSize: 11)),
                    Text(c.powerTx, style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                  if ((c.rstSent.isNotEmpty || c.rstReceived.isNotEmpty || c.powerTx.isNotEmpty) && c.powerRx.isNotEmpty) Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('|', style: TextStyle(color: textMuted, fontSize: 11))),
                  if (c.powerRx.isNotEmpty) ...[
                    Text('Rxp ', style: TextStyle(color: textSecondary, fontSize: 11)),
                    Text(c.powerRx, style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ]),
              ],
              // Row 3: Notes
              if (c.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(c.notes, style: TextStyle(color: textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ]))),
          ])),
        ),
      )),
    );
  }

  Widget _modePill(String mode, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? accent.withValues(alpha: 0.15) : Color.lerp(accent.withValues(alpha: 0.15), Colors.white, 0.5)!;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(mode, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'monospace')));
  }

  void _openQrz(String callsign) {
    final uri = Uri.parse('https://www.qrz.com/db/$callsign');
    ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
  }
}
