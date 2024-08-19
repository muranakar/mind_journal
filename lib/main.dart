import 'package:flutter/material.dart';
// import 'package:intl/date_symbol_data_http_request.dart';
// import 'package:intl/intl.dart';
import 'package:mind_journal/screen/calendar.dart';
import 'package:mind_journal/screen/diaryList.dart';
import 'package:mind_journal/screen/home.dart';
import 'package:mind_journal/screen/settings.dart';

void main() {
  // 日付フォーマットを初期化
  // initializeDateFormatting('ja_JP','ja_JP');
  // Intl.defaultLocale = 'ja_JP';
  runApp(const NavigationBarApp());
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeMode mode = ThemeMode.system;
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(),
      themeMode: mode,
      home: const NavigationExample(),
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
              child: HomeScreen(),
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
