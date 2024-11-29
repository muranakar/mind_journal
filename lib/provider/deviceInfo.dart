import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// デバイス情報の状態を定義
class DeviceInfo {
  final String font;
  final double fontSize;
  final double letterSpacing;
  final double lineHeight;
  final bool isDarkMode;

  const DeviceInfo({
    this.font = 'HannariMincho',
    this.fontSize = 14.0,
    this.letterSpacing = 0.0,
    this.lineHeight = 1.5,
    this.isDarkMode = false,
  });

  // copyWithメソッドで新しいインスタンスを生成
  DeviceInfo copyWith({
    String? font,
    double? fontSize,
    double? letterSpacing,
    double? lineHeight,
    bool? isDarkMode,
  }) {
    return DeviceInfo(
      font: font ?? this.font,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// SharedPreferencesのキー定数
class PrefsKeys {
  static const String font = 'font';
  static const String fontSize = 'fontSize';
  static const String letterSpacing = 'letterSpacing';
  static const String lineHeight = 'lineHeight';
  static const String isDarkMode = 'isDarkMode';
}

// デバイス情報の状態を管理するNotifier
class DeviceInfoNotifier extends StateNotifier<DeviceInfo> {
  DeviceInfoNotifier() : super(const DeviceInfo()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      state = DeviceInfo(
        font: prefs.getString(PrefsKeys.font) ?? 'HannariMincho',
        fontSize: prefs.getDouble(PrefsKeys.fontSize) ?? 14.0,
        letterSpacing: prefs.getDouble(PrefsKeys.letterSpacing) ?? 0.0,
        lineHeight: prefs.getDouble(PrefsKeys.lineHeight) ?? 1.5,
        isDarkMode: prefs.getBool(PrefsKeys.isDarkMode) ?? false,
      );
    } catch (e) {
      // エラーハンドリング
      print('設定の読み込みに失敗しました: $e');
    }
  }

  Future<void> updateFont(String font) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsKeys.font, font);
      state = state.copyWith(font: font);
    } catch (e) {
      print('フォントの更新に失敗しました: $e');
    }
  }

  Future<void> updateFontSize(double fontSize) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(PrefsKeys.fontSize, fontSize);
      state = state.copyWith(fontSize: fontSize);
    } catch (e) {
      print('フォントサイズの更新に失敗しました: $e');
    }
  }

  Future<void> updateLetterSpacing(double letterSpacing) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(PrefsKeys.letterSpacing, letterSpacing);
      state = state.copyWith(letterSpacing: letterSpacing);
    } catch (e) {
      print('文字間隔の更新に失敗しました: $e');
    }
  }

  Future<void> updateLineHeight(double lineHeight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(PrefsKeys.lineHeight, lineHeight);
      state = state.copyWith(lineHeight: lineHeight);
    } catch (e) {
      print('行の高さの更新に失敗しました: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newValue = !state.isDarkMode;
      await prefs.setBool(PrefsKeys.isDarkMode, newValue);
      state = state.copyWith(isDarkMode: newValue);
    } catch (e) {
      print('ダークモードの切り替えに失敗しました: $e');
    }
  }
}

// デバイス情報のプロバイダー
final deviceInfoProvider = StateNotifierProvider<DeviceInfoNotifier, DeviceInfo>((ref) {
  return DeviceInfoNotifier();
});

// 設定が読み込まれたかどうかを管理するプロバイダー
final settingsLoadedProvider = StateProvider<bool>((ref) => false);

// テキストスタイルを提供するプロバイダー
final textStyleProvider = Provider<TextStyle>((ref) {
  final deviceInfo = ref.watch(deviceInfoProvider);
  
  return TextStyle(
    fontFamily: deviceInfo.font,
    fontSize: deviceInfo.fontSize,
    letterSpacing: deviceInfo.letterSpacing,
    height: deviceInfo.lineHeight,
  );
});