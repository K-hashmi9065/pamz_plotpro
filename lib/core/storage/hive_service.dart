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
  }) async {
    await _sessionBox?.put('userId', userId);
    await _sessionBox?.put('username', username);
    await _sessionBox?.put('role', role);
    await _sessionBox?.put('loggedInAt', DateTime.now().toIso8601String());
  }

  static Map<String, dynamic>? getUserSession() {
    if (_sessionBox == null || !_sessionBox!.containsKey('userId')) {
      return null;
    }
    return {
      'userId': _sessionBox!.get('userId'),
      'username': _sessionBox!.get('username'),
      'role': _sessionBox!.get('role'),
      'loggedInAt': _sessionBox!.get('loggedInAt'),
    };
  }

  static Future<void> clearUserSession() async {
    await _sessionBox?.clear();
  }

  // --- Preferences & UI State ---
  static Future<void> setSidebarExpanded(bool expanded) async {
    await _settingsBox?.put('sidebarExpanded', expanded);
  }

  static bool getSidebarExpanded({bool defaultValue = true}) {
    return _settingsBox?.get('sidebarExpanded', defaultValue: defaultValue) ?? defaultValue;
  }

  static Future<void> setSelectedProjectFilter(String? projectId) async {
    await _settingsBox?.put('selectedProjectId', projectId);
  }

  static String? getSelectedProjectFilter() {
    return _settingsBox?.get('selectedProjectId');
  }
}
