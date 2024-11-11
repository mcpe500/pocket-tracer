import 'package:flutter/material.dart';
import 'package:pockettracer/services/storage_service.dart';

class ThemeService extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    _isDarkMode = await StorageService.getData<bool>(_darkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.storeData<bool>(_darkModeKey, _isDarkMode);
    notifyListeners();
  }
}
