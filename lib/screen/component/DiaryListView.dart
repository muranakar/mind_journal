import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/model/diary_notifier.dart';
import 'package:mind_journal/provider/deviceInfo.dart';

// 定数のグループ化
class DiaryListViewConstants {
  static const double verticalPadding = 2.0;
  static const double horizontalPadding = 6.0;
  static const double bubblePadding = 8.0;
  static const double chipSpacing = 3.0;
  static const double borderRadius = 12.0;
  static const double iconPadding = 2.0;
}

// テーマカラーのプロバイダー
final diaryListThemeProvider =
    Provider.family<DiaryListThemeColors, bool>((ref, isDarkMode) {
  return DiaryListThemeColors(isDarkMode: isDarkMode);
});

// テーマカラーを管理するクラス
class DiaryListThemeColors {
  final bool isDarkMode;

  DiaryListThemeColors({required this.isDarkMode});

  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF333333);
  Color get timeColor => isDarkMode ? Colors.grey : const Color(0xFF555555);
  Color get dateColor => isDarkMode ? Colors.grey : const Color(0xFF999999);
  Color get chipTextColor => const Color(0xFFFE91A1);
  Color get chipBackgroundColor =>
      isDarkMode ? const Color(0xFF3E3E3E) : const Color(0xFFFEF3F3);
  Color get favoriteColor =>
      isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFFE91A1);
  Color get favoriteBorderColor =>
      isDarkMode ? Colors.grey : const Color(0xFF999999);
  Color get deleteBackgroundColor =>
      isDarkMode ? const Color(0xFFFF4444) : Colors.redAccent;
}

class DiaryListView extends ConsumerWidget {
  final List<Diary> diaries;
  final bool isLineStyleUI;

  const DiaryListView({
    super.key,
    required this.diaries,
    this.isLineStyleUI = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredDiaries = ref.watch(filteredDiariesProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);
    final themeColors =
        ref.watch(diaryListThemeProvider(deviceInfo.isDarkMode));

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical:
            deviceInfo.lineHeight * DiaryListViewConstants.verticalPadding,
        horizontal: DiaryListViewConstants.horizontalPadding,
      ),
      itemCount: diaries.length,
      itemBuilder: (context, index) {
        final diary = diaries[index];
        final timeString = _formatTime(diary.createdAt);
        final dateString = _formatDate(diary.createdAt);
        final watchDiary = ref.watch(diariesProvider
            .select((state) => state.firstWhere((d) => d.id == diary.id)));
        final isFavorite = ref.watch(diariesProvider.select(
            (state) => state.firstWhere((d) => d.id == diary.id).isFavorite));

        return Dismissible(
          key: Key('diary_${diary.id}'), // ユニークなキーに変更
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _onDeleteDiary(ref, diary.id!, context),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(
              right: DiaryListViewConstants.horizontalPadding,
            ),
            color: themeColors.deleteBackgroundColor,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: deviceInfo.fontSize * 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DiaryListViewConstants.verticalPadding,
            ),
            child: isLineStyleUI
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            DiaryListViewConstants.bubblePadding),
                        decoration: BoxDecoration(
                          color: themeColors.backgroundColor,
                          borderRadius: BorderRadius.circular(
                              DiaryListViewConstants.borderRadius),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          timeString,
                          style: TextStyle(
                            color: themeColors.timeColor,
                            fontSize: deviceInfo.fontSize * 0.5,
                            fontFamily: deviceInfo.font,
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: DiaryListViewConstants.horizontalPadding / 2),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                            DiaryListViewConstants.bubblePadding,
                            DiaryListViewConstants.bubblePadding,
                            0,
                            0,
                          ),
                          decoration: BoxDecoration(
                            color: themeColors.backgroundColor,
                            borderRadius: BorderRadius.circular(
                                DiaryListViewConstants.borderRadius),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diary.content,
                                style: TextStyle(
                                  color: themeColors.textColor,
                                  fontSize: deviceInfo.fontSize * 0.85,
                                  fontFamily: deviceInfo.font,
                                  height: deviceInfo.lineHeight,
                                  letterSpacing: deviceInfo.letterSpacing,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                            DiaryListViewConstants.bubblePadding,
                            DiaryListViewConstants.bubblePadding,
                            0,
                            0,
                          ),
                          decoration: BoxDecoration(
                            color: themeColors.backgroundColor,
                            borderRadius: BorderRadius.circular(
                                DiaryListViewConstants.borderRadius),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diary.content,
                                style: TextStyle(
                                  color: themeColors.textColor,
                                  fontSize: deviceInfo.fontSize * 0.85,
                                  fontFamily: deviceInfo.font,
                                  height: deviceInfo.lineHeight,
                                  letterSpacing: deviceInfo.letterSpacing,
                                ),
                              ),
                              if (dateString != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      dateString,
                                      style: TextStyle(
                                        color: themeColors.dateColor,
                                        fontSize: deviceInfo.fontSize * 0.6,
                                        fontFamily: deviceInfo.font,
                                      ),
                                    ),
                                    Hero(
                                      tag: 'favorite_button_${diary.id}',
                                      child: IconButton(
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? themeColors.favoriteColor
                                              : themeColors.favoriteBorderColor,
                                          size: deviceInfo.fontSize * 0.85,
                                        ),
                                        onPressed: () async {
                                          await ref
                                              .read(diariesProvider.notifier)
                                              .toggleFavorite(watchDiary);
                                        },
                                        padding: EdgeInsets.all(
                                            DiaryListViewConstants.iconPadding),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _onToggleFavorite(WidgetRef ref, Diary diary) async {
    await ref.read(diariesProvider.notifier).toggleFavorite(diary);
  }

  void _onDeleteDiary(WidgetRef ref, int id, BuildContext context) async {
    await ref.read(diariesProvider.notifier).deleteDiary(id);
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.year}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.day.toString().padLeft(2, '0')} "
        "${_formatTime(dateTime)}";
  }
}
