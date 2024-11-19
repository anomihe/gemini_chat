import 'package:chat_with_ai/localStore/boxes.dart';
import 'package:chat_with_ai/localStore/setting.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _shouldSpeak = false;
  bool get isDarkMode => _isDarkMode;
  bool get shouldSpeak => _shouldSpeak;
  void update(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  void getSavedSettings() {
    final settingsBox = Boxes.getSetting();
    if (settingsBox.isNotEmpty) {
      final settings = settingsBox.getAt(0);

      _isDarkMode = settings!.darkTheme;

      _shouldSpeak = settings.shouldSpeak;
    }
  }

  //toggle the dark mode
  void toggleDarkMode({required bool value, Settings? setting}) {
    if (setting != null) {
      setting.darkTheme = value;
      setting.save();
    } else {
      final settingsBox = Boxes.getSetting();
      settingsBox.putAt(
          0, Settings(darkTheme: value, shouldSpeak: shouldSpeak));
    }
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleShouldSpeak({required bool value, Settings? setting}) {
    if (setting != null) {
      setting.shouldSpeak = value;
      setting.save();
    } else {
      final settingsBox = Boxes.getSetting();
      settingsBox.putAt(0, Settings(darkTheme: isDarkMode, shouldSpeak: value));
    }
    _shouldSpeak = value;
    notifyListeners();
  }
}
