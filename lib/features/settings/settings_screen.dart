import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import '../../core/design/app_colors.dart';
import '../../utils/timezone_util.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/preferences/app_preferences.dart';
import '../../services/adif_exporter.dart';
import '../../services/adif_importer.dart';
import '../../services/cloudlog_sync_service.dart';
import '../../services/location_service.dart';
import '../../services/update_checker.dart';
import '../../services/equipment_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyFocus = FocusNode();
  final _apiKeyDisplayCtrl = _MaskedController();
  final _callsignCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _equipCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _gridCtrl = TextEditingController();
  final _cloudUrlCtrl = TextEditingController();
  final _cloudKeyCtrl = TextEditingController();
  bool _autoUpload = false;
  String _timezone = TimezoneUtil.defaultZone;
  String _gridSquare = '';
  int _totalContacts = 0;
  bool _syncing = false;
  bool _testingConn = false;
  String? _testConnResult;
  String _syncResult = '';
  String _stationProfileId = '1';
  List<StationInfo> _stationList = [];
  List<String> _antennaList = [];
  List<EquipmentCategory> _rigList = [];
  String _newAntenna = '', _newRigBrand = '', _newRigModel = '';

  @override
  void initState() {
    super.initState();
    _apiKeyDisplayCtrl.realCtrl = _cloudKeyCtrl;
    _apiKeyFocus.addListener(() => setState(() {}));
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    await AppPreferences.init();
    final db = ref.read(dbProvider);
    final total = await db.contactDao.getTotalCount();
    final antennas = await EquipmentManager.getAntennas();
    final rigs = await EquipmentManager.getRigs();
    setState(() {
      _callsignCtrl.text = AppPreferences.callsign;
    _timezone = AppPreferences.timezone;
      _nameCtrl.text = AppPreferences.opName;
      _equipCtrl.text = AppPreferences.equipment;
      _locCtrl.text = AppPreferences.location;
      _gridCtrl.text = AppPreferences.gridSquare;
      _cloudUrlCtrl.text = AppPreferences.cloudlogUrl;
      _cloudKeyCtrl.text = AppPreferences.cloudlogApiKey;
      _apiKeyDisplayCtrl.notifyListeners();
      _autoUpload = AppPreferences.autoUploadEnabled;
      _stationProfileId = AppPreferences.stationProfileId;
      _stationList = StationInfo.fromJsonList(AppPreferences.stationListJson);
      _timezone = AppPreferences.timezone;
      _gridSquare = AppPreferences.gridSquare;
      _totalContacts = total;
      _antennaList = antennas;
      _rigList = rigs;
    });
  }

  Future<void> _savePref(String key, String value) async {
    switch (key) {
      case 'callsign': AppPreferences.callsign = value; break;
      case 'opName': AppPreferences.opName = value; break;
      case 'equipment': AppPreferences.equipment = value; break;
      case 'location': AppPreferences.location = value; break;
      case 'gridSquare': AppPreferences.gridSquare = value; break;
      case 'cloudlogUrl': AppPreferences.cloudlogUrl = value; break;
      case 'cloudlogApiKey': AppPreferences.cloudlogApiKey = value; break;
    }
  }

  Future<void> _getLocation() async {
    final result = await LocationService.getCurrent();
    if (result != null) {
      setState(() {
        _gridCtrl.text = result.grid;
        _locCtrl.text = result.address;
        _gridSquare = result.grid;
      });
      _savePref('gridSquare', result.grid);
      _savePref('location', result.address);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('无法获取位置'), backgroundColor: AppColors.alertRed));
    }
  }

  Future<void> _exportAdif() async {
    final db = ref.read(dbProvider);
    final contacts = await db.contactDao.getAllContacts();
    if (contacts.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('暂无通联数据'))); return; }
    final content = AdifExporter.export(contacts);
    final tmp = await getTemporaryDirectory();
    final file = File('${tmp.path}/hamlog_export.adi');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], subject: 'QSO日志导出');
  }

  Future<void> _importAdif() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.first.path!);
    final content = await file.readAsString();
    final records = AdifImporter.parse(content);
    final db = ref.read(dbProvider);
    int imported = 0;
    for (final r in records) {
      try {
        await db.contactDao.insertContact(ContactRecordsCompanion(
          dateEpochDay: Value(r.dateEpochDay), callsign: Value(r.callsign),
          frequencyMHz: Value(r.frequencyMHz), mode: Value(r.mode),
          rstSent: Value(r.rstSent), rstReceived: Value(r.rstReceived),
          powerTx: Value(r.powerTx), powerRx: Value(r.powerRx),
          notes: Value(r.notes), createdAt: Value(r.createdAt),
        ));
        imported++;
      } catch (_) {}
    }
    _loadPrefs();
    ref.read(homeRefreshNotifier.notifier).state++;
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导入完成：$imported / ${records.length} 条'), backgroundColor: AppColors.primary));
  }

  Future<void> _syncCloudlog() async {
    if (_cloudUrlCtrl.text.isEmpty || _cloudKeyCtrl.text.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请先配置 Cloudlog URL 和 API Key'), backgroundColor: AppColors.alertRed));
      return;
    }
    setState(() { _syncing = true; _syncResult = ''; });
    final db = ref.read(dbProvider);
    final contacts = await db.contactDao.getAllContacts();
    final service = CloudlogSyncService();
    final result = await service.syncContacts(
      baseUrl: _cloudUrlCtrl.text, apiKey: _cloudKeyCtrl.text,
      contacts: contacts, callsign: _callsignCtrl.text,
      gridSquare: _gridSquare, stationProfileId: AppPreferences.stationProfileId,
    );
    setState(() {
      _syncing = false;
      _syncResult = '成功: ${result.success}  失败: ${result.failed}';
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_syncResult), backgroundColor: result.failed > 0 ? AppColors.alertRed : AppColors.primary));
  }

  Future<void> _testCloudlogConnection() async {
    if (_cloudUrlCtrl.text.isEmpty || _cloudKeyCtrl.text.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请先配置 Cloudlog URL 和 API Key'), backgroundColor: AppColors.alertRed));
      return;
    }
    setState(() { _testingConn = true; _testConnResult = null; });
    final service = CloudlogSyncService();
    final ok = await service.testConnection(_cloudUrlCtrl.text, _cloudKeyCtrl.text);
    if (ok) {
      try {
        final stations = await service.fetchStationInfo(_cloudUrlCtrl.text, _cloudKeyCtrl.text);
        AppPreferences.stationListJson = StationInfo.toJsonList(stations);
        if (mounted) setState(() { _testingConn = false; _testConnResult = '连接成功'; _stationList = stations; });
      } catch (_) {
        if (mounted) setState(() { _testingConn = false; _testConnResult = '连接成功'; });
      }
    } else {
      if (mounted) setState(() { _testingConn = false; _testConnResult = '连接失败'; });
    }
  }

  void _showAutoUploadHelp() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(ctx).brightness == Brightness.dark ? AppColors.surface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('自动上传说明', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.textPrimary : const Color(0xFF1B1C1D))),
      content: Text('开启后如果保存的通联日志有错误，则需要手动在 Cloudlog 后台删除。Cloudlog 未提供删除 API，所以无法自动删除。', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('知道了', style: TextStyle(color: AppColors.amber)))],
    ));
  }

  void _openGitHub() {
    final uri = Uri.parse('https://github.com/walker6253/qso-keeper');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _addAntenna() async {
    if (_newAntenna.trim().isEmpty) return;
    _antennaList.add(_newAntenna.trim());
    await EquipmentManager.setAntennas(_antennaList);
    setState(() => _newAntenna = '');
  }

  Future<void> _deleteAntenna(int idx) async {
    _antennaList.removeAt(idx);
    await EquipmentManager.setAntennas(_antennaList);
    setState(() {});
  }

  Future<void> _addRig() async {
    if (_newRigBrand.trim().isEmpty) return;
    final idx = _rigList.indexWhere((c) => c.brand == _newRigBrand.trim());
    if (idx >= 0) {
      if (_newRigModel.trim().isNotEmpty) _rigList[idx].models.add(_newRigModel.trim());
    } else {
      _rigList.add(EquipmentCategory(_newRigBrand.trim(), _newRigModel.trim().isNotEmpty ? [_newRigModel.trim()] : []));
    }
    await EquipmentManager.setRigs(_rigList);
    setState(() { _newRigBrand = ''; _newRigModel = ''; });
  }

  Future<void> _deleteRigModel(String brand, String model) async {
    final idx = _rigList.indexWhere((c) => c.brand == brand);
    if (idx >= 0) {
      _rigList[idx].models.remove(model);
      if (_rigList[idx].models.isEmpty) _rigList.removeAt(idx);
    }
    await EquipmentManager.setRigs(_rigList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = isDark ? AppColors.surface : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1B1C1D);
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF434653);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF777680);
    final inputFill = isDark ? AppColors.surfaceLight : const Color(0xFFF5F3F4);
    final borderColor = isDark ? AppColors.border.withValues(alpha: 0.3) : const Color(0xFFC3C6D5);
    final pad = MediaQuery.of(context).padding;
    final safeSide = pad.left > pad.right ? pad.left : pad.right;
    final safeBottom = pad.bottom > safeSide ? pad.bottom : safeSide;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('设置', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
      ),
      body: Padding(padding: EdgeInsets.fromLTRB(safeSide, 0, safeSide, 0), child: ListView(padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + safeBottom), children: [
        _sectionTitle('OP 信息', icon: Icons.person, titleColor: textPrimary),
        const SizedBox(height: 8),
        _textField('呼号', _callsignCtrl, (v) => _savePref('callsign', v), textPrimary, textSecondary, inputFill, borderColor),
        _textField('姓名', _nameCtrl, (v) => _savePref('opName', v), textPrimary, textSecondary, inputFill, borderColor),
        _textField('设备', _equipCtrl, (v) => _savePref('equipment', v), textPrimary, textSecondary, inputFill, borderColor),
        const SizedBox(height: 16),
        _sectionTitle('时区', icon: Icons.schedule, titleColor: textPrimary),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DropdownButtonFormField<String>(
            value: _timezone,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true, fillColor: inputFill, isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
            ),
            style: TextStyle(fontSize: 13, color: textPrimary),
            dropdownColor: isDark ? AppColors.surfaceLight : Colors.white,
            items: TimezoneUtil.zoneIds.map((z) => DropdownMenuItem(value: z, child: Text(TimezoneUtil.displayName(z), style: TextStyle(fontSize: 12, color: textPrimary)))).toList(),
            onChanged: (v) { if (v != null) { setState(() => _timezone = v); _savePref('timezone', v); } },
          ),
        ),
        const SizedBox(height: 8),
        _sectionTitle('天线管理', icon: Icons.settings_input_antenna, titleColor: textPrimary),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _antennaList.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex--;
            await EquipmentManager.moveAntenna(oldIndex, newIndex);
            setState(() { final item = _antennaList.removeAt(oldIndex); _antennaList.insert(newIndex, item); });
          },
          buildDefaultDragHandles: false,
          itemBuilder: (_, i) => Padding(
            key: ValueKey('ant_' + _antennaList[i]),
            padding: const EdgeInsets.only(bottom: 1),
            child: Row(children: [
              ReorderableDragStartListener(index: i, child: Icon(Icons.drag_handle, size: 18, color: textSecondary.withValues(alpha: 0.4))),
              const SizedBox(width: 4),
              Expanded(child: Text(_antennaList[i], style: TextStyle(color: textPrimary, fontSize: 13))),
              IconButton(icon: Icon(Icons.delete_outline, size: 18, color: AppColors.alertRed.withValues(alpha: 0.6)), onPressed: () => _deleteAntenna(i)),
            ]),
          ),
        ),
        Row(children: [
          Expanded(child: TextField(decoration: InputDecoration(hintText: '新天线', isDense: true, filled: true, fillColor: inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor))),
            style: TextStyle(fontSize: 12, color: textPrimary), onChanged: (v) => _newAntenna = v)),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _addAntenna, style: ElevatedButton.styleFrom(backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary), child: Text('添加', style: TextStyle(fontSize: 11, color: Colors.white))),
        ]),
        const SizedBox(height: 16),
        _sectionTitle('设备管理', icon: Icons.build, titleColor: textPrimary),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rigList.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex--;
            await EquipmentManager.moveRigBrand(oldIndex, newIndex);
            setState(() { final item = _rigList.removeAt(oldIndex); _rigList.insert(newIndex, item); });
          },
          buildDefaultDragHandles: false,
          itemBuilder: (_, i) {
            final cat = _rigList[i];
            return Padding(
              key: ValueKey('rig_' + cat.brand),
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  ReorderableDragStartListener(index: i, child: Icon(Icons.drag_handle, size: 16, color: textSecondary.withValues(alpha: 0.4))),
                  const SizedBox(width: 6),
                  Expanded(child: Text(cat.brand, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: textPrimary))),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? AppColors.surface : Colors.white,
                        title: Text('删除品牌', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                        content: Text('确定删除 "' + cat.brand + '" 及其所有型号？', style: TextStyle(color: textSecondary, fontSize: 13)),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('取消', style: TextStyle(color: textMuted))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('删除', style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.w600)))],
                      ));
                      if (confirmed == true) { await EquipmentManager.removeRigBrand(cat.brand); setState(() => _rigList.removeWhere((x) => x.brand == cat.brand)); }
                    },
                    child: Icon(Icons.delete_outline, size: 16, color: AppColors.alertRed.withValues(alpha: 0.5)),
                  ),
                ]),
                const SizedBox(height: 2),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cat.models.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIdx, newIdx) async {
                    if (newIdx > oldIdx) newIdx--;
                    final newList = _rigList.toList();
                    final bi = newList.indexWhere((x) => x.brand == cat.brand);
                    if (bi >= 0) {
                      final models = List<String>.from(newList[bi].models);
                      final item = models.removeAt(oldIdx);
                      models.insert(newIdx, item);
                      newList[bi] = EquipmentCategory(cat.brand, models);
                      await EquipmentManager.setRigs(newList);
                      setState(() { _rigList[bi] = EquipmentCategory(cat.brand, models); });
                    }
                  },
                  itemBuilder: (_, mi) {
                    final m = cat.models[mi];
                    return Padding(
                      key: ValueKey('model_' + cat.brand + '_' + m),
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Row(children: [
                        const SizedBox(width: 24),
                        ReorderableDragStartListener(index: mi, child: Icon(Icons.drag_handle, size: 14, color: textSecondary.withValues(alpha: 0.3))),
                        const SizedBox(width: 4),
                        Expanded(child: Text(m, style: TextStyle(color: textPrimary, fontSize: 12))),
                        IconButton(icon: Icon(Icons.delete_outline, size: 14, color: AppColors.alertRed.withValues(alpha: 0.5)), onPressed: () async {
                          final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                            backgroundColor: isDark ? AppColors.surface : Colors.white,
                            title: Text('删除型号', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15)),
                            content: Text('确定删除 ' + cat.brand + ' - ' + m + ' ？', style: TextStyle(color: textSecondary, fontSize: 13)),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('取消', style: TextStyle(color: textMuted))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('删除', style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.w600)))],
                          ));
                          if (confirmed == true) { _deleteRigModel(cat.brand, m); }
                        }),
                      ]),
                    );
                  },
                ),
              ]),
            );
          },
        ),
        Row(children: [
          Expanded(flex: 2, child: TextField(decoration: InputDecoration(hintText: '品牌', isDense: true, filled: true, fillColor: inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor))),
            style: TextStyle(fontSize: 12, color: textPrimary), onChanged: (v) => _newRigBrand = v)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: TextField(decoration: InputDecoration(hintText: '型号', isDense: true, filled: true, fillColor: inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor))),
            style: TextStyle(fontSize: 12, color: textPrimary), onChanged: (v) => _newRigModel = v)),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _addRig, style: ElevatedButton.styleFrom(backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary), child: Text('添加', style: TextStyle(fontSize: 11, color: Colors.white))),
        ]),
        const SizedBox(height: 16),
        _sectionTitle('Cloudlog 同步', icon: Icons.cloud, titleColor: textPrimary),
        const SizedBox(height: 8),
        _textField('URL', _cloudUrlCtrl, (v) => _savePref('cloudlogUrl', v), textPrimary, textSecondary, inputFill, borderColor),
        Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(bottom: 4, left: 2), child: Text('API Key', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1))),
          TextField(
            controller: _apiKeyFocus.hasFocus ? _cloudKeyCtrl : _apiKeyDisplayCtrl,
            onChanged: (v) => _savePref('cloudlogApiKey', v),
            focusNode: _apiKeyFocus,
            style: TextStyle(color: textPrimary, fontSize: 13, fontFamily: 'monospace'),
            decoration: InputDecoration(
              filled: true, fillColor: inputFill, isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
              suffixIcon: IconButton(
                icon: Icon(_apiKeyFocus.hasFocus ? Icons.visibility : Icons.visibility_off, size: 18, color: textSecondary),
                onPressed: () { if (_apiKeyFocus.hasFocus) { _apiKeyFocus.unfocus(); } else { _apiKeyFocus.requestFocus(); } },
              ),
            ),
          ),
        ])),
        Row(children: [
          GestureDetector(
            onTap: () => _showAutoUploadHelp(),
            child: Row(children: [
              Text('保存日志后自动上传', style: TextStyle(color: textSecondary, fontSize: 13)),
              const SizedBox(width: 4),
              Icon(Icons.help_outline, size: 14, color: textSecondary.withValues(alpha: 0.6)),
            ]),
          ),
          const Spacer(),
          Switch(value: _autoUpload, onChanged: (v) { setState(() => _autoUpload = v); AppPreferences.autoUploadEnabled = v; }, activeColor: AppColors.primary, inactiveTrackColor: inputFill),
        ]),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(bottom: 4, left: 2), child: Text('台站 ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1))),
            DropdownButtonFormField<String>(
              value: _stationProfileId,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true, fillColor: inputFill, isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
              ),
              style: TextStyle(fontSize: 13, color: textPrimary),
              dropdownColor: isDark ? AppColors.surfaceLight : Colors.white,
              items: _stationList.isEmpty
                ? [DropdownMenuItem(value: _stationProfileId, child: Text(_stationProfileId, style: TextStyle(fontSize: 12, color: textSecondary)))]
                : _stationList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name + ' (' + s.id + ')', style: TextStyle(fontSize: 12, color: textPrimary)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _stationProfileId = v); AppPreferences.stationProfileId = v; } },
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: (_cloudUrlCtrl.text.isNotEmpty && !_testingConn && !_syncing) ? _testCloudlogConnection : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: _testConnResult != null ? (_testConnResult == '连接成功' ? AppColors.scopeGreen : AppColors.alertRed) : textSecondary,
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _testingConn
              ? Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: textSecondary)), const SizedBox(width: 6), Text('测试中...', style: TextStyle(fontSize: 12))])
              : Text(_testConnResult ?? '测试连接', style: TextStyle(fontSize: 12)),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: _syncing ? null : _syncCloudlog,
            icon: _syncing ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.cloud_upload),
            label: Text(_syncing ? '同步中...' : '手动同步'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
        ]),
        if (_syncResult.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_syncResult, style: TextStyle(color: textSecondary, fontSize: 12))),
        const SizedBox(height: 16),
        _sectionTitle('数据管理', icon: Icons.folder, titleColor: textPrimary),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: _exportAdif, icon: Icon(Icons.file_upload), label: Text('导出 ADIF'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: _importAdif, icon: Icon(Icons.file_download), label: Text('导入 ADIF'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('关于', icon: Icons.info_outline, titleColor: textPrimary),
        const SizedBox(height: 8),
        TextButton(onPressed: () async { final info = await UpdateChecker.check(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info.hasUpdate ? '有新版本 v${info.latestVersion}' : '已是最新版本 v${info.currentVersion}'))); },
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.centerLeft),
          child: Text('检查更新', style: TextStyle(color: AppColors.ionBlue, fontSize: 12))),
        const SizedBox(height: 20),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Designed by BI9BRH', style: TextStyle(color: textMuted.withValues(alpha: 0.5), fontSize: 11)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _openGitHub(),
              child: CustomPaint(size: const Size(14, 14), painter: _GitHubPainter(textMuted.withValues(alpha: 0.5))),
            ),
          ]),
          Text('Contributors: BI9CGB', style: TextStyle(color: textMuted.withValues(alpha: 0.4), fontSize: 10)),
        ])),
        const SizedBox(height: 80),
      ])),
    );
  }

  Widget _sectionTitle(String title, {IconData? icon, Color titleColor = const Color(0xFF1B1C1D)}) => Row(children: [
    if (icon != null) ...[Icon(icon, size: 16, color: AppColors.primary), const SizedBox(width: 6)],
    Text(title, style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w700)),
  ]);

  Widget _textField(String label, TextEditingController ctrl, Function(String) onChanged, Color textPrimary, Color textSecondary, Color inputFill, Color border) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 4, left: 2), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1))),
      TextField(
        controller: ctrl, onChanged: onChanged,
        style: TextStyle(color: textPrimary, fontSize: 13),
        decoration: InputDecoration(
          filled: true, fillColor: inputFill, isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
        ),
      ),
    ]));

  @override
  void dispose() {
    _callsignCtrl.dispose(); _nameCtrl.dispose(); _equipCtrl.dispose();
    _locCtrl.dispose(); _gridCtrl.dispose(); _cloudUrlCtrl.dispose(); _cloudKeyCtrl.dispose();
    _apiKeyDisplayCtrl.dispose();
    _apiKeyFocus.dispose();
    super.dispose();
  }
}


// API Key 脱敏：失焦时前后各4字符可见，中间用*遮盖
class _MaskedController extends TextEditingController {
  TextEditingController? realCtrl;

  static String _mask(String raw) {
    if (raw.length <= 8) return raw;
    final prefix = raw.substring(0, 4);
    final suffix = raw.substring(raw.length - 4);
    final stars = '*' * (raw.length - 8);
    return prefix + stars + suffix;
  }

  @override
  String get text => realCtrl != null ? _mask(realCtrl!.text) : '';

  @override
  set text(String _) {}

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    return TextSpan(text: text, style: style);
  }
}

class _GitHubPainter extends CustomPainter {
  final Color color;
  _GitHubPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true;
    final s = size.width / 24.0;
    canvas.translate(0, 0);
    final path = ui.Path()..moveTo(12*s, 2*s)..lineTo(12*s, 2*s);
    path.reset();
    path.moveTo(12*s, 2*s);
    path.addOval(Rect.fromLTWH(2*s, 2*s, 20*s, 20*s));
    final inner = ui.Path()..addOval(Rect.fromLTWH(3.5*s, 3.5*s, 17*s, 17*s));
    final combined = ui.Path.combine(ui.PathOperation.difference, path, inner);
    canvas.drawPath(combined, p);
    final body = ui.Path();
    body.moveTo(12*s, 4.2*s);
    body.cubicTo(7.7*s, 4.2*s, 4.2*s, 7.7*s, 4.2*s, 12*s);
    body.cubicTo(4.2*s, 15.4*s, 6.4*s, 18.3*s, 9.45*s, 19.35*s);
    body.cubicTo(9.83*s, 19.42*s, 9.96*s, 19.19*s, 9.96*s, 18.99*s);
    body.lineTo(9.96*s, 18.09*s);
    body.cubicTo(7.82*s, 18.54*s, 7.37*s, 17.14*s, 7.37*s, 17.14*s);
    body.cubicTo(7.03*s, 16.32*s, 6.55*s, 16.11*s, 6.55*s, 16.11*s);
    body.cubicTo(5.87*s, 15.66*s, 6.59*s, 15.67*s, 6.59*s, 15.67*s);
    body.cubicTo(7.33*s, 15.72*s, 7.72*s, 16.43*s, 7.72*s, 16.43*s);
    body.cubicTo(8.36*s, 17.52*s, 9.44*s, 17.2*s, 9.86*s, 17.02*s);
    body.cubicTo(9.92*s, 16.55*s, 10.12*s, 16.23*s, 10.33*s, 16.05*s);
    body.cubicTo(8.68*s, 15.87*s, 6.93*s, 15.23*s, 6.93*s, 12.01*s);
    body.cubicTo(6.93*s, 11.15*s, 7.23*s, 10.46*s, 7.72*s, 9.91*s);
    body.cubicTo(7.64*s, 9.71*s, 7.38*s, 8.86*s, 7.8*s, 7.73*s);
    body.cubicTo(7.8*s, 7.73*s, 8.48*s, 7.52*s, 9.94*s, 8.53*s);
    body.cubicTo(10.6*s, 8.35*s, 11.31*s, 8.26*s, 12.03*s, 8.26*s);
    body.cubicTo(12.75*s, 8.26*s, 13.47*s, 8.35*s, 14.13*s, 8.53*s);
    body.cubicTo(15.59*s, 7.52*s, 16.27*s, 7.73*s, 16.27*s, 7.73*s);
    body.cubicTo(16.69*s, 8.86*s, 16.43*s, 9.71*s, 16.35*s, 9.91*s);
    body.cubicTo(16.84*s, 10.46*s, 17.14*s, 11.15*s, 17.14*s, 12.01*s);
    body.cubicTo(17.14*s, 15.24*s, 15.39*s, 15.87*s, 13.72*s, 16.04*s);
    body.cubicTo(14*s, 16.27*s, 14.28*s, 16.72*s, 14.28*s, 17.47*s);
    body.lineTo(14.28*s, 18.99*s);
    body.cubicTo(14.28*s, 19.19*s, 14.4*s, 19.43*s, 14.8*s, 19.35*s);
    body.cubicTo(17.84*s, 18.3*s, 20.04*s, 15.4*s, 20.04*s, 12*s);
    body.cubicTo(20.04*s, 7.7*s, 16.54*s, 4.2*s, 12.24*s, 4.2*s);
    body.close();
    canvas.drawPath(body, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
