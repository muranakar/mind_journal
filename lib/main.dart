import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/screen/calendar/calendar.dart';
import 'package:mind_journal/screen/diaryList/diaryList.dart';
import 'package:mind_journal/screen/home/home.dart';
import 'package:mind_journal/screen/settingScreen/settingFont.dart';
import 'package:mind_journal/screen/settingScreen/settings.dart';
import 'package:mind_journal/screen/tag/tagSearch.dart';
import 'package:mind_journal/screen/tag/tag_filtered_diarylist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 画面のルート名を定数で管理
class Routes {
  static const String home = '/';
  static const String calendar = '/calendar';
  static const String tagSearch = '/tag-search';
  static const String diaryList = '/diary-list';
  static const String settings = '/settings';
  static const String tagFilteredList = '/tag-filtered-list';
  static const String fontSelection = '/font-selection';
}

// UI関連の定数
class UIConstants {
  // FloatingActionButton関連
  static const double floatingButtonIconSize = 24.0;
  static const double floatingButtonElevation = 0.0;
  static const double floatingButtonShadowBlurRadius = 10.0;
  static const double floatingButtonShadowSpreadRadius = 1.0;
  static const shadowOffset = Offset(0, 5);

  // ライトモードの色
  static const Color lightIndicatorColor = Color(0xFFB2DFDB);
  static const Color lightFloatingButtonColor = Color(0xFF81C784);
  static const Color lightFloatingButtonIconColor = Colors.white;
  static const Color lightHomeIconColor = Colors.teal;
  static const Color lightCalendarIconColor = Colors.cyan;
  static const Color lightListIconColor = Colors.teal;
  static const Color lightSettingsIconColor = Colors.blueGrey;
  static const Color lightTagSearchIconColor = Colors.orange;

  // ダークモードの色
  static const Color darkIndicatorColor = Color(0xFF37474F);
  static const Color darkFloatingButtonColor = Color(0xFF81C784);
  static const Color darkFloatingButtonIconColor = Colors.white;
  static const Color darkHomeIconColor = Colors.grey;
  static const Color darkCalendarIconColor = Colors.grey;
  static const Color darkListIconColor = Colors.grey;
  static const Color darkSettingsIconColor = Colors.grey;
  static const Color darkTagSearchIconColor = Colors.orange;

  // ラベル
  static const String homeLabel = 'Home';
  static const String calendarLabel = 'Calendar';
  static const String listLabel = 'List';
  static const String settingsLabel = 'Settings';
  static const String tagSearchLabel = 'Tag';
}

// SharedPreferencesのキー
class PrefsKeys {
  static const String font = 'font';
  static const String fontSize = 'fontSize';
  static const String letterSpacing = 'letterSpacing';
  static const String lineHeight = 'lineHeight';
  static const String isDarkMode = 'isDarkMode';
}

// デバイス情報モデル
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

// デバイス情報の状態管理
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

// プロバイダー群
final deviceInfoProvider = StateNotifierProvider<DeviceInfoNotifier, DeviceInfo>((ref) {
  return DeviceInfoNotifier();
});

final currentPageProvider = StateProvider<int>((ref) => 0);

final textStyleProvider = Provider<TextStyle>((ref) {
  final deviceInfo = ref.watch(deviceInfoProvider);
  return TextStyle(
    fontFamily: deviceInfo.font,
    fontSize: deviceInfo.fontSize,
    letterSpacing: deviceInfo.letterSpacing,
    height: deviceInfo.lineHeight,
  );
});

void main() {
  runApp(const ProviderScope(child: NavigationBarApp()));
}

class NavigationBarApp extends ConsumerWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceInfo = ref.watch(deviceInfoProvider);

    return MaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: deviceInfo.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => const NavigationExample(),
        Routes.tagFilteredList: (context) => const TagFilteredDiaryListScreen(),
        Routes.fontSelection: (context) => const FontSelectionScreen(),
      },
    );
  }
}

class NavigationExample extends ConsumerWidget {
  const NavigationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPageIndex = ref.watch(currentPageProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);
    final isDarkMode = deviceInfo.isDarkMode;

    final colors = _getThemeColors(isDarkMode);

    return Scaffold(
      bottomNavigationBar: _buildNavigationBar(ref, currentPageIndex, colors),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          HomeScreen(onTabSelected: (index) {
            ref.read(currentPageProvider.notifier).state = index;
          }),
          const DiaryListWithCalendarScreen(),
          const TagSearchScreen(),
          const DiaryListScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(
        currentPageIndex, 
        ref,
        colors,
      ),
    );
  }

  ThemeColors _getThemeColors(bool isDarkMode) {
    return ThemeColors(
      indicatorColor: isDarkMode ? UIConstants.darkIndicatorColor : UIConstants.lightIndicatorColor,
      floatingButtonColor: isDarkMode ? UIConstants.darkFloatingButtonColor : UIConstants.lightFloatingButtonColor,
      floatingButtonIconColor: isDarkMode ? UIConstants.darkFloatingButtonIconColor : UIConstants.lightFloatingButtonIconColor,
      homeIconColor: isDarkMode ? UIConstants.darkHomeIconColor : UIConstants.lightHomeIconColor,
      calendarIconColor: isDarkMode ? UIConstants.darkCalendarIconColor : UIConstants.lightCalendarIconColor,
      listIconColor: isDarkMode ? UIConstants.darkListIconColor : UIConstants.lightListIconColor,
      settingsIconColor: isDarkMode ? UIConstants.darkSettingsIconColor : UIConstants.lightSettingsIconColor,
      tagSearchIconColor: isDarkMode ? UIConstants.darkListIconColor : UIConstants.lightListIconColor,
    );
  }

  Widget _buildNavigationBar(WidgetRef ref, int currentPageIndex, ThemeColors colors) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        ref.read(currentPageProvider.notifier).state = index;
      },
      indicatorColor: colors.indicatorColor,
      selectedIndex: currentPageIndex,
      destinations: _buildDestinations(colors),
    );
  }

  List<NavigationDestination> _buildDestinations(ThemeColors colors) {
    return [
      NavigationDestination(
        selectedIcon: const Icon(Icons.note_alt_outlined),
        icon: Icon(Icons.note_alt_outlined, color: colors.homeIconColor),
        label: UIConstants.homeLabel,
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined, color: colors.calendarIconColor),
        label: UIConstants.calendarLabel,
      ),
      NavigationDestination(
        icon: Icon(Icons.tag, color: colors.tagSearchIconColor),
        label: UIConstants.tagSearchLabel,
      ),
      NavigationDestination(
        icon: Icon(Icons.list_alt, color: colors.listIconColor),
        label: UIConstants.listLabel,
      ),
      NavigationDestination(
        icon: Icon(Icons.settings, color: colors.settingsIconColor),
        label: UIConstants.settingsLabel,
      ),
    ];
  }

  Widget? _buildFloatingActionButton(
    int currentPageIndex,
    WidgetRef ref,
    ThemeColors colors,
  ) {
    if (currentPageIndex == 1 || currentPageIndex == 2 || currentPageIndex == 3) {
      return FloatingActionButton(
        onPressed: () {
          ref.read(currentPageProvider.notifier).state = 0;
        },
        backgroundColor: Colors.transparent,
        elevation: UIConstants.floatingButtonElevation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.floatingButtonColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: UIConstants.floatingButtonShadowSpreadRadius,
                blurRadius: UIConstants.floatingButtonShadowBlurRadius,
                offset: UIConstants.shadowOffset,
              ),
            ],
          ),
          child: Icon(
            Icons.mode,
            color: colors.floatingButtonIconColor,
            size: UIConstants.floatingButtonIconSize,
          ),
        ),
      );
    }
    return null;
  }
}

// テーマカラー管理用のクラス
class ThemeColors {
  final Color indicatorColor;
  final Color floatingButtonColor;
  final Color floatingButtonIconColor;
  final Color homeIconColor;
  final Color calendarIconColor;
  final Color listIconColor;
  final Color settingsIconColor;
  final Color tagSearchIconColor;

  ThemeColors({
    required this.indicatorColor,
    required this.floatingButtonColor,
    required this.floatingButtonIconColor,
    required this.homeIconColor,
    required this.calendarIconColor,
    required this.listIconColor,
    required this.settingsIconColor,
    required this.tagSearchIconColor,
  });
}

// 画面遷移のための拡張メソッド
extension NavigationExtension on BuildContext {
  void navigateToTagFilteredList(List<String> tags) {
    Navigator.pushNamed(
      this,
      Routes.tagFilteredList,
      arguments: tags,
    );
  }

  void navigateToFontSelection() {
    Navigator.pushNamed(this, Routes.fontSelection);
  }
}