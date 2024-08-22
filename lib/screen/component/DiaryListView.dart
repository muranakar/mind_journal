import 'package:flutter/material.dart';
import 'package:mind_journal/model/deviceInfo.dart';
import 'package:provider/provider.dart';
import 'package:mind_journal/model/diary.dart';

class DiaryListView extends StatelessWidget {
  final List<Diary> diaries;
  final Function(Diary) onToggleFavorite;
  final Function(int) onDeleteDiary;
  final bool displayTimeLeft;

  DiaryListView({
    required this.diaries,
    required this.onToggleFavorite,
    required this.onDeleteDiary,
    this.displayTimeLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceInfo>(
      builder: (context, deviceInfo, child) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(
              vertical: deviceInfo.lineHeight * 2, horizontal: 6.0),
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
                padding: EdgeInsets.only(right: 6.0),
                color: Colors.redAccent,
                child: Icon(Icons.delete,
                    color: Colors.white, size: deviceInfo.fontSize * 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (displayTimeLeft)
                      // 左側に時間を表示
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
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
                            color: Color(0xFF555555),
                            fontSize: deviceInfo.fontSize * 0.7,
                            fontFamily: deviceInfo.font,
                          ),
                        ),
                      ),
                    if (displayTimeLeft) SizedBox(width: 3.0),
                    // メッセージバブル
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
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
                                color: Color(0xFF333333),
                                fontSize: deviceInfo.fontSize * 0.85,
                                fontFamily: deviceInfo.font,
                                height: deviceInfo.lineHeight,
                                letterSpacing: deviceInfo.letterSpacing,
                              ),
                            ),
                            if (diary.tags.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 1.0),
                                child: Wrap(
                                  spacing: 3.0,
                                  runSpacing: 1.0,
                                  children: diary.tags.map((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      backgroundColor: Color(0xFFFEF3F3),
                                      labelStyle: TextStyle(
                                        color: Color(0xFFFE91A1),
                                        fontSize: deviceInfo.fontSize * 0.7,
                                        fontFamily: deviceInfo.font,
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
                                      color: Color(0xFF999999),
                                      fontSize: deviceInfo.fontSize * 0.7,
                                      fontFamily: deviceInfo.font,
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
                                          ? Color(0xFFFE91A1)
                                          : Color(0xFF999999),
                                      size: deviceInfo.fontSize * 0.85,
                                    ),
                                    onPressed: () => onToggleFavorite(diary),
                                    padding: EdgeInsets.all(2.0),
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
      },
    );
  }
}
