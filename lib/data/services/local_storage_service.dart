import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _sessionUserKey = 'session_current_user_id';
  static const String _dbDataPrefix = 'hogwarts_db_';

  static Future<void> saveCurrentUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_sessionUserKey);
    } else {
      await prefs.setString(_sessionUserKey, userId);
    }
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionUserKey);
  }

  static Future<void> saveCollection(
      String collectionName, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items);
    await prefs.setString('$_dbDataPrefix$collectionName', jsonString);
  }

  static Future<List<Map<String, dynamic>>?> loadCollection(
      String collectionName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_dbDataPrefix$collectionName');
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
