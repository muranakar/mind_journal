import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';
import 'package:table_calendar/table_calendar.dart';

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

// 選択された日付を管理するプロバイダー
final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

// フォーカスされた日付を管理するプロバイダー
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// カレンダーフォーマットを管理するプロバイダー
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) => CalendarFormat.week);

// 日付ごとの日記を管理するプロバイダー
final diariesByDateProvider = Provider<Map<DateTime, List<Diary>>>((ref) {
  final diaries = ref.watch(diariesProvider);
  final diariesByDate = <DateTime, List<Diary>>{};
  
  for (var diary in diaries) {
    final date = DateTime(
      diary.createdAt.year,
      diary.createdAt.month,
      diary.createdAt.day
    );
    if (diariesByDate[date] == null) {
      diariesByDate[date] = [];
    }
    diariesByDate[date]!.add(diary);
  }
  
  return diariesByDate;
});

// 選択された日付の日記を取得するプロバイダー
final selectedDateDiariesProvider = Provider<List<Diary>>((ref) {
  final selectedDay = ref.watch(selectedDayProvider);
  final diariesByDate = ref.watch(diariesByDateProvider);
  
  if (selectedDay == null) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return diariesByDate[today] ?? [];
  }
  
  final selectedDate = DateTime(
    selectedDay.year,
    selectedDay.month,
    selectedDay.day
  );
  return diariesByDate[selectedDate] ?? [];
});

class DiaryListWithCalendarScreen extends ConsumerWidget {
  const DiaryListWithCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);
    final diariesByDate = ref.watch(diariesByDateProvider);
    final selectedDiaries = ref.watch(selectedDateDiariesProvider);
    final diaryNotifier = ref.watch(diariesProvider.notifier);

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
            focusedDay: focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(selectedDayProvider.notifier).state = selectedDay;
              ref.read(focusedDayProvider.notifier).state = focusedDay;
            },
            calendarFormat: calendarFormat,
            onFormatChanged: (format) {
              ref.read(calendarFormatProvider.notifier).state = format;
            },
            onPageChanged: (focusedDay) {
              ref.read(focusedDayProvider.notifier).state = focusedDay;
            },
            eventLoader: (day) {
              return diariesByDate[day] ?? [];
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
            child: ref.watch(diariesProvider).isEmpty
              ? const Center(
                  child: Text(
                    noDiaryMessage,
                    style: TextStyle(
                      fontSize: fontSizeForNoDiaryMessage,
                      color: errorColor,
                    ),
                  ),
                )
              : DiaryListView(
                  diaries: selectedDiaries,
                  onToggleFavorite: (diary) async {
                    await diaryNotifier.updateDiary(
                      diary.copyWith(isFavorite: !diary.isFavorite)
                    );
                  },
                  onDeleteDiary: (id) async {
                    await diaryNotifier.deleteDiary(id);
                  },
                  isLineStyleUI: true,
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