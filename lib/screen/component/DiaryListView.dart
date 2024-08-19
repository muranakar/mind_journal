import 'package:flutter/material.dart';
import 'package:mind_journal/model/diary.dart';

class DiaryListView extends StatelessWidget {
  final List<Diary> diaries;
  final Function(Diary) onToggleFavorite;
  final Function(int) onDeleteDiary;
  final bool displayTimeLeft;

  // 色の定数
  static const Color backgroundColor = Colors.white;
  static const Color bubbleColor = Colors.white;
  static const Color bubbleShadowColor = Colors.black12;
  static const Color timeTextColor = Color(0xFF555555);
  static const Color contentTextColor = Color(0xFF333333);
  static const Color tagBackgroundColor = Color(0xFFFEF3F3);
  static const Color tagTextColor = Color(0xFFFE91A1);
  static const Color dateTextColor = Color(0xFF999999);
  static const Color favoriteIconColor = Color(0xFFFE91A1);
  static const Color favoriteIconBorderColor = Color(0xFF999999);
  static const Color deleteIconColor = Colors.white;
  static const Color deleteBackgroundColor = Colors.redAccent;

  // その他の定数
  static const double paddingVertical = 2.0;
  static const double paddingHorizontal = 6.0;
  static const double timeFontSize = 10.0;
  static const double contentFontSize = 12.0;
  static const double tagFontSize = 10.0;
  static const double iconSize = 12.0;
  static const double bubblePadding = 8.0;
  static const double borderRadius = 12.0;
  static const double iconButtonPadding = 2.0;

  DiaryListView({
    required this.diaries,
    required this.onToggleFavorite,
    required this.onDeleteDiary,
    this.displayTimeLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
          vertical: paddingVertical, horizontal: paddingHorizontal),
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
            padding: EdgeInsets.only(right: paddingHorizontal),
            color: deleteBackgroundColor,
            child: Icon(Icons.delete,
                color: deleteIconColor, size: iconSize * 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: paddingVertical),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (displayTimeLeft)
                  // 左側に時間を表示
                  Container(
                    padding: EdgeInsets.all(bubblePadding),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: bubbleShadowColor,
                          offset: Offset(0, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      timeString,
                      style: TextStyle(
                        color: timeTextColor,
                        fontSize: timeFontSize,
                      ),
                    ),
                  ),
                if (displayTimeLeft) SizedBox(width: paddingHorizontal / 2),
                // メッセージバブル
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(bubblePadding),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: bubbleShadowColor,
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
                            color: contentTextColor,
                            fontSize: contentFontSize,
                          ),
                        ),
                        if (diary.tags.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: paddingVertical / 2),
                            child: Wrap(
                              spacing: paddingHorizontal / 2,
                              runSpacing: paddingVertical / 2,
                              children: diary.tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: tagBackgroundColor,
                                  labelStyle: TextStyle(
                                    color: tagTextColor,
                                    fontSize: tagFontSize,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 右下に時間を表示
                            if (!displayTimeLeft)
                              Text(
                                dateString,
                                style: TextStyle(
                                  color: dateTextColor,
                                  fontSize: timeFontSize,
                                ),
                              ),
                            // ハートのアイコン
                            if (!displayTimeLeft)
                              IconButton(
                                icon: Icon(
                                  diary.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: diary.isFavorite
                                      ? favoriteIconColor
                                      : favoriteIconBorderColor,
                                  size: iconSize,
                                ),
                                onPressed: () => onToggleFavorite(diary),
                                padding: EdgeInsets.all(iconButtonPadding),
                                constraints: BoxConstraints(),
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
}
