import 'package:flutter/material.dart';
import 'package:mind_journal/provider/deviceInfo.dart';
import 'package:provider/provider.dart';
import 'package:mind_journal/screen/calendar.dart';
import 'package:mind_journal/screen/diaryList.dart';
import 'package:mind_journal/screen/home.dart';
import 'package:mind_journal/screen/settings.dart'; // DeviceInfoのインポート

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
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.green[100],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.note_alt_outlined),
            icon: Icon(Icons.note_alt_outlined, color: Colors.teal),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.cyan),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt, color: Colors.teal),
            label: 'List',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings,
              color: Colors.blueGrey,
            ),
            label: 'Sample',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
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
                // ここに日記を追加する画面への遷移などの処理を実装
                setState(() {
                  currentPageIndex = 0;
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[300], // 背景色を指定
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // 影の色を指定
                      spreadRadius: 1, // 影の広がりを指定
                      blurRadius: 10, // 影のぼかし具合を指定
                      offset: Offset(0, 5), // 影の位置を指定 (x, y)
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mode,
                  color: Colors.white, // アイコンの色を白に指定
                  size: 24.0, // アイコンのサイズを調整
                ),
              ),
              backgroundColor: Colors.transparent, // ボタンの背景を透明にする
              elevation: 0.0, // デフォルトの影を削除
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
