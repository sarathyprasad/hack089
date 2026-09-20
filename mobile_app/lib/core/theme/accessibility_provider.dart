import 'package:flutter/material.dart';
import '../storage/storage_service.dart';

class AccessibilityProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _highContrast = false;
  double _fontScale = 1.0;

  bool get isDarkMode => _isDarkMode;
  bool get highContrast => _highContrast;
  double get fontScale => _fontScale;

  AccessibilityProvider() {
    _isDarkMode = StorageService.getDarkMode();
    _highContrast = StorageService.getHighContrast();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    StorageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool enabled) {
    _isDarkMode = enabled;
    StorageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    StorageService.saveHighContrast(_highContrast);
    notifyListeners();
  }

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }

  void resetAccessibility() {
    _isDarkMode = false;
    _highContrast = false;
    _fontScale = 1.0;
    StorageService.saveDarkMode(false);
    StorageService.saveHighContrast(false);
    notifyListeners();
  }
}
