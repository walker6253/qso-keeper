import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo { final bool hasUpdate; final String latestVersion; final String currentVersion; final String releaseUrl; final String body; const UpdateInfo({this.hasUpdate=false, this.latestVersion='', this.currentVersion='', this.releaseUrl='', this.body=''}); }

class UpdateChecker {
  static const _api = 'https://api.github.com/repos/walker6253/ham-logs-flutter/releases/latest';
  static final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  static Future<UpdateInfo> check() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final cur = pkg.version;
      final resp = await _dio.get(_api);
      final tag = (resp.data['tag_name'] as String).replaceFirst('v', '');
      final body = resp.data['body'] as String? ?? '';
      final htmlUrl = resp.data['html_url'] as String? ?? '';
      final hasUpdate = _compareVersions(tag, cur) > 0;
      return UpdateInfo(hasUpdate: hasUpdate, latestVersion: tag, currentVersion: cur, releaseUrl: htmlUrl, body: body);
    } catch (_) { return UpdateInfo(); }
  }

  static int _compareVersions(String v1, String v2) {
    final p1 = v1.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final p2 = v2.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final maxLen = p1.length > p2.length ? p1.length : p2.length;
    for (int i = 0; i < maxLen; i++) {
      final a = i < p1.length ? p1[i] : 0; final b = i < p2.length ? p2[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }
}
