import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

/// Local Hive key-value storage service for session, preferences, and UI state.
class HiveService {
  static const String settingsBoxName = 'settings_box';
  static const String sessionBoxName = 'session_box';

  static Box? _settingsBox;
  static Box? _sessionBox;

  static Box? get _effectiveSettingsBox {
    if (_settingsBox != null && _settingsBox!.isOpen) return _settingsBox;
    if (Hive.isBoxOpen(settingsBoxName)) return Hive.box(settingsBoxName);
    return null;
  }

  static Box? get _effectiveSessionBox {
    if (_sessionBox != null && _sessionBox!.isOpen) return _sessionBox;
    if (Hive.isBoxOpen(sessionBoxName)) return Hive.box(sessionBoxName);
    return null;
  }

  static Future<void> init() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final hiveDir = Directory(p.join(appSupportDir.path, AppConstants.appDataFolder, 'hive'));
    if (!await hiveDir.exists()) {
      await hiveDir.create(recursive: true);
    }
    await Hive.initFlutter(hiveDir.path);

    _settingsBox = await Hive.openBox(settingsBoxName);
    _sessionBox = await Hive.openBox(sessionBoxName);
  }

  // --- Session Storage ---
  static Future<void> saveUserSession({
    required String userId,
    required String username,
    required String role,
    String? memberType,
  }) async {
    await _effectiveSessionBox?.put('userId', userId);
    await _effectiveSessionBox?.put('username', username);
    await _effectiveSessionBox?.put('role', role);
    await _effectiveSessionBox?.put('memberType', memberType ?? '');
    await _effectiveSessionBox?.put('loggedInAt', DateTime.now().toIso8601String());
  }


  static Map<String, dynamic>? getUserSession() {
    final box = _effectiveSessionBox;
    if (box == null || !box.containsKey('userId')) {
      return null;
    }
    return {
      'userId': box.get('userId'),
      'username': box.get('username'),
      'role': box.get('role'),
      'loggedInAt': box.get('loggedInAt'),
    };
  }

  static Future<void> clearUserSession() async {
    await _effectiveSessionBox?.clear();
  }

  // --- Preferences & UI State ---
  static Future<void> setSidebarExpanded(bool expanded) async {
    await _effectiveSettingsBox?.put('sidebarExpanded', expanded);
  }

  static bool getSidebarExpanded({bool defaultValue = true}) {
    return _effectiveSettingsBox?.get('sidebarExpanded', defaultValue: defaultValue) ?? defaultValue;
  }

  static Future<void> setSelectedProjectFilter(String? projectId) async {
    await _effectiveSettingsBox?.put('selectedProjectId', projectId);
  }

  static String? getSelectedProjectFilter() {
    return _effectiveSettingsBox?.get('selectedProjectId');
  }

  // --- PDF Header Branding ---
  static Future<void> setPdfHeaderTitle(String title) async {
    await _effectiveSettingsBox?.put('pdfHeaderTitle', title.trim());
  }

  static String getPdfHeaderTitle({String defaultValue = 'PAMZ PlotPro'}) {
    final val = _effectiveSettingsBox?.get('pdfHeaderTitle');
    if (val != null && val.toString().trim().isNotEmpty) {
      return val.toString().trim();
    }
    return defaultValue;
  }
}
