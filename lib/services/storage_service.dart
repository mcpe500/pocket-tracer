import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<T?> getData<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == List<Map<String, dynamic>>) {
      final String? data = prefs.getString(key);
      if (data != null) {
        return (json.decode(data) as List).cast<Map<String, dynamic>>() as T?;
      }
    }
    return null;
  }

  static Future<void> storeData<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<Map<String, dynamic>>) {
      await prefs.setString(key, json.encode(value));
    }
  }
}
