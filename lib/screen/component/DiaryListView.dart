import 'package:flutter/material.dart';
import 'package:mind_journal/provider/deviceInfo.dart';
import 'package:mind_journal/screen/component/FavoriteButton.dart';
import 'package:provider/provider.dart';
import 'package:mind_journal/model/diary.dart';

class DiaryListView extends StatelessWidget {
  final List<Diary> diaries;
  final Function(Diary) onToggleFavorite;
  final Function(int) onDeleteDiary;
  final bool isLineStyleUI;

  // 定数化されたレイアウトに関する数値
  static const double verticalPadding = 2.0;
  static const double horizontalPadding = 6.0;
  static const double bubblePadding = 8.0;
  static const double chipSpacing = 3.0;
  static const double borderRadius = 12.0;
  static const double iconPadding = 2.0;

  const DiaryListView({
    super.key,
    required this.diaries,
    required this.onToggleFavorite,
    required this.onDeleteDiary,
    this.isLineStyleUI = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceInfo>(
      builder: (context, deviceInfo, child) {
        final isDarkMode = deviceInfo.isDarkMode;

        // テーマに応じた色の定義
        final Color backgroundColor =
            isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final Color textColor =
            isDarkMode ? Colors.white : const Color(0xFF333333);
        final Color timeColor =
            isDarkMode ? Colors.grey : const Color(0xFF555555);
        final Color dateColor =
            isDarkMode ? Colors.grey : const Color(0xFF999999);
        final Color chipTextColor =
            isDarkMode ? const Color(0xFFFE91A1) : const Color(0xFFFE91A1);
        final Color chipBackgroundColor =
            isDarkMode ? const Color(0xFF3E3E3E) : const Color(0xFFFEF3F3);
        final Color favoriteColor =
            isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFFE91A1);
        final Color favoriteBorderColor =
            isDarkMode ? Colors.grey : const Color(0xFF999999);
        final Color deleteBackgroundColor =
            isDarkMode ? const Color(0xFFFF4444) : Colors.redAccent;

        return ListView.builder(
          padding: EdgeInsets.symmetric(
              vertical: deviceInfo.lineHeight * verticalPadding,
              horizontal: horizontalPadding),
          itemCount: diaries.length,
          itemBuilder: (context, index) {
            final diary = diaries[index];
            final timeString =
                "${diary.createdAt.hour.toString().padLeft(2, '0')}:${diary.createdAt.minute.toString().padLeft(2, '0')}";
            final dateString =
                "${diary.createdAt.year}/${diary.createdAt.month.toString().padLeft(2, '0')}/${diary.createdAt.day.toString().padLeft(2, '0')} $timeString";

            return Dismissible(
              key: Key(diary.id.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                onDeleteDiary(diary.id!);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: horizontalPadding),
                color: deleteBackgroundColor,
                child: Icon(Icons.delete,
                    color: Colors.white, size: deviceInfo.fontSize * 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: verticalPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isLineStyleUI)
                      // 左側に時間を表示
                      Container(
                        padding: const EdgeInsets.all(bubblePadding),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(borderRadius),
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
                            color: timeColor,
                            fontSize: deviceInfo.fontSize * 0.5,
                            fontFamily: deviceInfo.font,
                          ),
                        ),
                      ),
                    if (isLineStyleUI)
                      const SizedBox(width: horizontalPadding / 2),
                    if (!isLineStyleUI)
                      // メッセージバブル
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                              bubblePadding, bubblePadding, 0, 0),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(borderRadius),
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
                                  color: textColor,
                                  fontSize: deviceInfo.fontSize * 0.85,
                                  fontFamily: deviceInfo.font,
                                  height: deviceInfo.lineHeight,
                                  letterSpacing: deviceInfo.letterSpacing,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // 右下に時間を表示
                                  Text(
                                    dateString,
                                    style: TextStyle(
                                      color: dateColor,
                                      fontSize: deviceInfo.fontSize * 0.6,
                                      fontFamily: deviceInfo.font,
                                    ),
                                  ),
                                  FavoriteButton(
                                    diary: diary,
                                    onToggleFavorite: onToggleFavorite,
                                    favoriteColor: favoriteColor,
                                    favoriteBorderColor: favoriteBorderColor,
                                    iconPadding: iconPadding,
                                    fontSize: deviceInfo.fontSize,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isLineStyleUI)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(bubblePadding),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(borderRadius),
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
                                  color: textColor,
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}
