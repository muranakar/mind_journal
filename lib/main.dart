import 'package:flutter/material.dart';
import 'package:mind_journal/provider/deviceInfo.dart';
import 'package:provider/provider.dart';
import 'package:mind_journal/screen/calendar/calendar.dart';
import 'package:mind_journal/screen/diaryList/diaryList.dart';
import 'package:mind_journal/screen/home/home.dart';
import 'package:mind_journal/screen/settingScreen/settings.dart';
import 'package:mind_journal/screen/tag/tagSearch.dart';

// 共通定数の定義
const double floatingButtonIconSize = 24.0;
const double floatingButtonElevation = 0.0;
const double floatingButtonShadowBlurRadius = 10.0;
const double floatingButtonShadowSpreadRadius = 1.0;
const Offset floatingButtonShadowOffset = Offset(0, 5);

// ライトモードの色定数
const Color lightIndicatorColor = Color(0xFFB2DFDB);
const Color lightFloatingButtonColor = Color(0xFF81C784);
const Color lightFloatingButtonIconColor = Colors.white;
const Color lightHomeIconColor = Colors.teal;
const Color lightCalendarIconColor = Colors.cyan;
const Color lightListIconColor = Colors.teal;
const Color lightSettingsIconColor = Colors.blueGrey;
const Color lightTagSearchIconColor = Colors.orange; 

// ダークモードの色定数
const Color darkIndicatorColor = Color(0xFF37474F);
const Color darkFloatingButtonColor = Color(0xFF81C784);
const Color darkFloatingButtonIconColor = Colors.white;
const Color darkHomeIconColor = Colors.grey;
const Color darkCalendarIconColor = Colors.grey;
const Color darkListIconColor = Colors.grey;
const Color darkSettingsIconColor = Colors.grey;
const Color darkTagSearchIconColor = Colors.orange;

// 文言定数
const String homeLabel = 'Home';
const String calendarLabel = 'Calendar';
const String listLabel = 'List';
const String settingsLabel = 'Settings';
const String tagSearchLabel = 'Tag'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DeviceInfo(),
      child: const NavigationBarApp(),
    ),
  );
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceInfo>(
      builder: (context, deviceInfo, child) {
        return MaterialApp(
          darkTheme: ThemeData.dark(),
          themeMode: deviceInfo.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const NavigationExample(),
        );
      },
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceInfo = Provider.of<DeviceInfo>(context);
    final bool isDarkMode = deviceInfo.isDarkMode;

    // ダークモード対応の色を選択
    final Color indicatorColor = isDarkMode ? darkIndicatorColor : lightIndicatorColor;
    final Color floatingButtonColor = isDarkMode ? darkFloatingButtonColor : lightFloatingButtonColor;
    final Color floatingButtonIconColor = isDarkMode ? darkFloatingButtonIconColor : lightFloatingButtonIconColor;
    final Color homeIconColor = isDarkMode ? darkHomeIconColor : lightHomeIconColor;
    final Color calendarIconColor = isDarkMode ? darkCalendarIconColor : lightCalendarIconColor;
    final Color listIconColor = isDarkMode ? darkListIconColor : lightListIconColor;
    final Color settingsIconColor = isDarkMode ? darkSettingsIconColor : lightSettingsIconColor;
    final Color tagSearchIconColor = isDarkMode ? darkListIconColor : lightListIconColor;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: indicatorColor,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: const Icon(Icons.note_alt_outlined),
            icon: Icon(Icons.note_alt_outlined, color: homeIconColor),
            label: homeLabel,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: calendarIconColor),
            label: calendarLabel,
          ),
          NavigationDestination( // 新しいタグ検索画面へのアイコンを追加
            icon: Icon(Icons.tag, color: tagSearchIconColor),
            label: tagSearchLabel,
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt, color: listIconColor),
            label: listLabel,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings, color: settingsIconColor),
            label: settingsLabel,
          ),
          
        ],
      ),
      body: <Widget>[
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: HomeScreen(onTabSelected: _onTabSelected),
            ),
          ),
        ),
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: DiaryListWithCalendarScreen(),
            ),
          ),
        ),
        Card( // 新しいタグ検索画面を追加
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: TagSearchScreen(), // タグ検索画面の表示
            ),
          ),
        ),
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: DiaryListScreen(),
            ),
          ),
        ),
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: SettingsScreen(),
            ),
          ),
        ),
        
      ][currentPageIndex],
      floatingActionButton: (currentPageIndex == 1 ||
              currentPageIndex == 2 ||
              currentPageIndex == 3)
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: floatingButtonElevation,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: floatingButtonColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: floatingButtonShadowSpreadRadius,
                      blurRadius: floatingButtonShadowBlurRadius,
                      offset: floatingButtonShadowOffset,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mode,
                  color: floatingButtonIconColor,
                  size: floatingButtonIconSize,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
