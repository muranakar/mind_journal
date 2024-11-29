import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/screen/settingScreen/settingFont.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 初期設定の読み込み
    Future.microtask(() {
      ref.read(deviceInfoProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceInfo = ref.watch(deviceInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '設定',
          style: TextStyle(fontFamily: deviceInfo.font),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(
              'ダークモード',
              style: TextStyle(fontFamily: deviceInfo.font),
            ),
            value: deviceInfo.isDarkMode,
            onChanged: (value) {
              ref.read(deviceInfoProvider.notifier).toggleDarkMode();
            },
          ),
          ListTile(
            title: Text(
              'フォント設定',
              style: TextStyle(fontFamily: deviceInfo.font),
            ),
            subtitle: Text('現在のフォント: ${deviceInfo.font}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FontSelectionScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// DeviceInfoのモデルクラス
class DeviceInfo {
  final bool isDarkMode;
  final String font;
  final double fontSize;
  final double letterSpacing;
  final double lineHeight;

  const DeviceInfo({
    this.isDarkMode = false,
    this.font = 'Default',
    this.fontSize = 16.0,
    this.letterSpacing = 1.0,
    this.lineHeight = 1.5,
  });

  DeviceInfo copyWith({
    bool? isDarkMode,
    String? font,
    double? fontSize,
    double? letterSpacing,
    double? lineHeight,
  }) {
    return DeviceInfo(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      font: font ?? this.font,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

// DeviceInfoの状態を管理するNotifier
class DeviceInfoNotifier extends StateNotifier<DeviceInfo> {
  DeviceInfoNotifier() : super(const DeviceInfo());

  Future<void> loadSettings() async {
    // SharedPreferencesなどから設定を読み込む処理を実装
    // 例：
    // final prefs = await SharedPreferences.getInstance();
    // final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    // final font = prefs.getString('font') ?? 'Default';
    // state = state.copyWith(isDarkMode: isDarkMode, font: font);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _saveSettings();
  }

  void updateFont(String font) {
    state = state.copyWith(font: font);
    _saveSettings();
  }

  void updateFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize);
    _saveSettings();
  }

  void updateLetterSpacing(double letterSpacing) {
    state = state.copyWith(letterSpacing: letterSpacing);
    _saveSettings();
  }

  void updateLineHeight(double lineHeight) {
    state = state.copyWith(lineHeight: lineHeight);
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    // SharedPreferencesなどに設定を保存する処理を実装
    // 例：
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('isDarkMode', state.isDarkMode);
    // await prefs.setString('font', state.font);
  }
}

// DeviceInfoのプロバイダー
final deviceInfoProvider = StateNotifierProvider<DeviceInfoNotifier, DeviceInfo>((ref) {
  return DeviceInfoNotifier();
});