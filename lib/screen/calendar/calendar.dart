import 'package:flutter/material.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';

// 定数の定義
const Color primaryColor = Color(0xFFFE91A1);
const Color errorColor = Color(0xFF888888);
const Color markerColor = Colors.red;
const Color markerTextColor = Colors.white;
const String noDiaryMessage = 'まだ日記がありません';
const double appBarHeight = 0.0;
const double fontSizeForNoDiaryMessage = 18.0;
const double markerFontSize = 12.0;
const double markerPadding = 4.0;

class DiaryListWithCalendarScreen extends StatefulWidget {
  const DiaryListWithCalendarScreen({super.key});

  @override
  _DiaryListWithCalendarScreenState createState() =>
      _DiaryListWithCalendarScreenState();
}

class _DiaryListWithCalendarScreenState
    extends State<DiaryListWithCalendarScreen> {
  Future<List<Diary>>? _diaryList;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Diary>> _diariesByDate = {};
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _fetchDiaries();
  }

  Future<void> _fetchDiaries() async {
    final diaries = await DiaryDatabase.instance.readAllDiaries();
    setState(() {
      _diaryList = Future.value(diaries);
      _diariesByDate = _groupDiariesByDate(diaries);
    });
  }

  Map<DateTime, List<Diary>> _groupDiariesByDate(List<Diary> diaries) {
    Map<DateTime, List<Diary>> diariesByDate = {};
    for (var diary in diaries) {
      final date = DateTime(
          diary.createdAt.year, diary.createdAt.month, diary.createdAt.day);
      if (diariesByDate[date] == null) {
        diariesByDate[date] = [];
      }
      diariesByDate[date]!.add(diary);
    }
    return diariesByDate;
  }

  List<Diary> _getDiariesForSelectedDate() {
    var now = DateTime.now();
    var selectedDate = DateTime(now.year, now.month, now.day);
    if (_selectedDay != null) {
      selectedDate =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    }
    return _diariesByDate[selectedDate] ?? [];
  }

  Future<void> _toggleFavorite(Diary diary) async {
    diary.isFavorite = !diary.isFavorite;
    await DiaryDatabase.instance.updateDiary(diary);
    await _fetchDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await DiaryDatabase.instance.deleteDiary(id);
    await _fetchDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: AppBar(),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _diariesByDate[day] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildBadge(),
                  );
                }
                return null;
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Diary>>(
              future: _diaryList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: primaryColor));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('エラーが発生しました: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      noDiaryMessage,
                      style: TextStyle(
                        fontSize: fontSizeForNoDiaryMessage,
                        color: errorColor,
                      ),
                    ),
                  );
                }

                final diaries = _getDiariesForSelectedDate();

                return DiaryListView(
                  diaries: diaries,
                  onToggleFavorite: _toggleFavorite,
                  onDeleteDiary: _deleteDiary,
                  isLineStyleUI: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.all(markerPadding),
      decoration: const BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
      ),
      child: const Text(
        '•',
        style: TextStyle(
          color: markerTextColor,
          fontSize: markerFontSize,
        ),
      ),
    );
  }
}
