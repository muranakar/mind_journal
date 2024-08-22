import 'package:flutter/material.dart';
import 'package:mind_journal/model/deviceInfo.dart';
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
          theme: ThemeData(
            useMaterial3: true,
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                fontFamily: deviceInfo.font,
                fontSize: deviceInfo.fontSize,
                letterSpacing: deviceInfo.letterSpacing,
                height: deviceInfo.lineHeight,
              ),
              bodyMedium: TextStyle(
                fontFamily: deviceInfo.font,
                fontSize: deviceInfo.fontSize,
                letterSpacing: deviceInfo.letterSpacing,
                height: deviceInfo.lineHeight,
              ),
              // 他のテキストスタイルもここで設定可能
            ),
          ),
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
    );
  }
}
