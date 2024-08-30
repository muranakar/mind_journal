import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfo with ChangeNotifier {
  String _font = '';
  double _fontSize = 0.0;
  double _letterSpacing = 0.0;
  double _lineHeight = 0.0;
  bool _isDarkMode = false;

  String get font => _font.isEmpty ? 'ShipporiMincho' : _font;
  double get fontSize => _fontSize == 0.0 ? 14.0 : _fontSize;
  double get letterSpacing => _letterSpacing;
  double get lineHeight => _lineHeight == 0.0 ? 1.5 : _lineHeight;
  bool get isDarkMode => _isDarkMode;

  DeviceInfo() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _font = prefs.getString('font') ?? '';
    _fontSize = prefs.getDouble('fontSize') ?? 0.0;
    _letterSpacing = prefs.getDouble('letterSpacing') ?? 0.0;
    _lineHeight = prefs.getDouble('lineHeight') ?? 0.0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    final prefs = await SharedPreferences.getInstance();
    _font = font;
    prefs.setString('font', font);
    notifyListeners();
  }

  Future<void> setFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = fontSize;
    prefs.setDouble('fontSize', fontSize);
    notifyListeners();
  }

  Future<void> setLetterSpacing(double letterSpacing) async {
    final prefs = await SharedPreferences.getInstance();
    _letterSpacing = letterSpacing;
    prefs.setDouble('letterSpacing', letterSpacing);
    notifyListeners();
  }

  Future<void> setLineHeight(double lineHeight) async {
    final prefs = await SharedPreferences.getInstance();
    _lineHeight = lineHeight;
    prefs.setDouble('lineHeight', lineHeight);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = isDarkMode;
    prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }
}