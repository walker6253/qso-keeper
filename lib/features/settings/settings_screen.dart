import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:io';
import '../../core/design/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/preferences/app_preferences.dart';
import '../../services/adif_exporter.dart';
import '../../services/adif_importer.dart';
import '../../services/cloudlog_sync_service.dart';
import '../../services/location_service.dart';
import '../../services/update_checker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _callsignCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _equipCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _gridCtrl = TextEditingController();
  final _cloudUrlCtrl = TextEditingController();
  final _cloudKeyCtrl = TextEditingController();
  bool _autoUpload = false;
  String _timezone = 'Asia/Shanghai';
  String _gridSquare = '';
  int _totalContacts = 0;
  bool _syncing = false;
  String _syncResult = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    await AppPreferences.init();
    final db = ref.read(dbProvider);
    final total = await db.contactDao.getTotalCount();
    setState(() {
      _callsignCtrl.text = AppPreferences.callsign;
      _nameCtrl.text = AppPreferences.opName;
      _equipCtrl.text = AppPreferences.equipment;
      _locCtrl.text = AppPreferences.location;
      _gridCtrl.text = AppPreferences.gridSquare;
      _cloudUrlCtrl.text = AppPreferences.cloudlogUrl;
      _cloudKeyCtrl.text = AppPreferences.cloudlogApiKey;
      _autoUpload = AppPreferences.autoUploadEnabled;
      _timezone = AppPreferences.timezone;
      _gridSquare = AppPreferences.gridSquare;
      _totalContacts = total;
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
    await Share.shareXFiles([XFile(file.path)], subject: 'HAM日志导出');
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导入完成：$imported / ${records.length} 条'), backgroundColor: AppColors.scopeGreen));
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_syncResult), backgroundColor: result.failed > 0 ? AppColors.alertRed : AppColors.scopeGreen));
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('设置', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
      ),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        _sectionTitle('OP 信息'),
        const SizedBox(height: 8),
        _textField('呼号', _callsignCtrl, (v) => _savePref('callsign', v), textPrimary, textSecondary, inputFill, borderColor),
        _textField('姓名', _nameCtrl, (v) => _savePref('opName', v), textPrimary, textSecondary, inputFill, borderColor),
        _textField('设备', _equipCtrl, (v) => _savePref('equipment', v), textPrimary, textSecondary, inputFill, borderColor),
        const SizedBox(height: 12),
        _sectionTitle('位置 & 网格'),
        const SizedBox(height: 8),
        _textField('位置', _locCtrl, (v) => _savePref('location', v), textPrimary, textSecondary, inputFill, borderColor),
        Row(children: [
          Expanded(child: _textField('梅登海德网格', _gridCtrl, (v) => _savePref('gridSquare', v), textPrimary, textSecondary, inputFill, borderColor)),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _getLocation, style: ElevatedButton.styleFrom(backgroundColor: AppColors.ionBlue), child: Text('GPS', style: TextStyle(fontSize: 12))),
        ]),
        if (_gridSquare.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('📍 当前网格: $_gridSquare', style: TextStyle(color: AppColors.amber, fontSize: 12))),
        const SizedBox(height: 16),
        _sectionTitle('Cloudlog 同步'),
        const SizedBox(height: 8),
        _textField('URL', _cloudUrlCtrl, (v) => _savePref('cloudlogUrl', v), textPrimary, textSecondary, inputFill, borderColor),
        _textField('API Key', _cloudKeyCtrl, (v) => _savePref('cloudlogApiKey', v), textPrimary, textSecondary, inputFill, borderColor),
        Row(children: [
          Text('自动上传', style: TextStyle(color: textSecondary, fontSize: 13)),
          const Spacer(),
          Switch(value: _autoUpload, onChanged: (v) { setState(() => _autoUpload = v); AppPreferences.autoUploadEnabled = v; }, activeColor: AppColors.scopeGreen, inactiveTrackColor: inputFill),
        ]),
        const SizedBox(height: 8),
        ElevatedButton.icon(onPressed: _syncing ? null : _syncCloudlog,
          icon: _syncing ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.deep, strokeWidth: 2)) : Icon(Icons.cloud_upload),
          label: Text(_syncing ? '同步中...' : '手动同步'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber)),
        if (_syncResult.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_syncResult, style: TextStyle(color: textSecondary, fontSize: 12))),
        const SizedBox(height: 16),
        _sectionTitle('数据管理'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: _exportAdif, icon: Icon(Icons.file_upload), label: Text('导出 ADIF'), style: ElevatedButton.styleFrom(backgroundColor: inputFill))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(onPressed: _importAdif, icon: Icon(Icons.file_download), label: Text('导入 ADIF'), style: ElevatedButton.styleFrom(backgroundColor: inputFill))),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('关于'),
        const SizedBox(height: 8),
        Card(color: surfaceColor, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HAM 日志 v1.0.0', style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('总通联数: $_totalContacts', style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          TextButton(onPressed: () async { final info = await UpdateChecker.check(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info.hasUpdate ? '有新版本 v${info.latestVersion}' : '已是最新版本 v${info.currentVersion}'))); },
            child: Text('检查更新', style: TextStyle(color: AppColors.ionBlue, fontSize: 12))),
        ]))),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: TextStyle(color: AppColors.amber, fontSize: 14, fontWeight: FontWeight.w700));

  Widget _textField(String label, TextEditingController ctrl, Function(String) onChanged, Color textPrimary, Color textSecondary, Color inputFill, Color border) =>
    Padding(padding: const EdgeInsets.only(bottom: 8), child: TextField(
      controller: ctrl, onChanged: onChanged,
      style: TextStyle(color: textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: textSecondary),
        filled: true, fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
      ),
    ));

  @override
  void dispose() {
    _callsignCtrl.dispose(); _nameCtrl.dispose(); _equipCtrl.dispose();
    _locCtrl.dispose(); _gridCtrl.dispose(); _cloudUrlCtrl.dispose(); _cloudKeyCtrl.dispose();
    super.dispose();
  }
}
