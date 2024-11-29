import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/provider/deviceInfo.dart';
import 'package:mind_journal/screen/component/FavoriteButton.dart';

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
final diaryListThemeProvider = Provider.family<DiaryListThemeColors, bool>((ref, isDarkMode) {
  return DiaryListThemeColors(isDarkMode: isDarkMode);
});

// テーマカラーを管理するクラス
class DiaryListThemeColors {
  final bool isDarkMode;

  DiaryListThemeColors({required this.isDarkMode});

  Color get backgroundColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF333333);
  Color get timeColor => isDarkMode ? Colors.grey : const Color(0xFF555555);
  Color get dateColor => isDarkMode ? Colors.grey : const Color(0xFF999999);
  Color get chipTextColor => const Color(0xFFFE91A1);
  Color get chipBackgroundColor => isDarkMode ? const Color(0xFF3E3E3E) : const Color(0xFFFEF3F3);
  Color get favoriteColor => isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFFE91A1);
  Color get favoriteBorderColor => isDarkMode ? Colors.grey : const Color(0xFF999999);
  Color get deleteBackgroundColor => isDarkMode ? const Color(0xFFFF4444) : Colors.redAccent;
}

class DiaryListView extends ConsumerWidget {
  final List<Diary> diaries;
  final Function(Diary) onToggleFavorite;
  final Function(int) onDeleteDiary;
  final bool isLineStyleUI;

  const DiaryListView({
    super.key,
    required this.diaries,
    required this.onToggleFavorite,
    required this.onDeleteDiary,
    this.isLineStyleUI = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceInfo = ref.watch(deviceInfoProvider);
    final themeColors = ref.watch(diaryListThemeProvider(deviceInfo.isDarkMode));

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: deviceInfo.lineHeight * DiaryListViewConstants.verticalPadding,
        horizontal: DiaryListViewConstants.horizontalPadding,
      ),
      itemCount: diaries.length,
      itemBuilder: (context, index) {
        final diary = diaries[index];
        return _buildDiaryItem(
          context,
          diary,
          deviceInfo,
          themeColors,
        );
      },
    );
  }

  Widget _buildDiaryItem(
    BuildContext context,
    Diary diary,
    DeviceInfo deviceInfo,
    DiaryListThemeColors colors,
  ) {
    final timeString = _formatTime(diary.createdAt);
    final dateString = _formatDate(diary.createdAt);

    return Dismissible(
      key: Key(diary.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDeleteDiary(diary.id!),
      background: _buildDismissBackground(deviceInfo, colors),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DiaryListViewConstants.verticalPadding,
        ),
        child: isLineStyleUI
            ? _buildLineStyleItem(diary, timeString, deviceInfo, colors)
            : _buildBubbleStyleItem(diary, dateString, deviceInfo, colors),
      ),
    );
  }

  Widget _buildDismissBackground(DeviceInfo deviceInfo, DiaryListThemeColors colors) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(
        right: DiaryListViewConstants.horizontalPadding,
      ),
      color: colors.deleteBackgroundColor,
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: deviceInfo.fontSize * 1.5,
      ),
    );
  }

  Widget _buildLineStyleItem(
    Diary diary,
    String timeString,
    DeviceInfo deviceInfo,
    DiaryListThemeColors colors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTimeContainer(timeString, deviceInfo, colors),
        const SizedBox(width: DiaryListViewConstants.horizontalPadding / 2),
        Expanded(
          child: _buildContentContainer(
            diary.content,
            null,
            deviceInfo,
            colors,
            showDate: false,
          ),
        ),
      ],
    );
  }

  Widget _buildBubbleStyleItem(
    Diary diary,
    String dateString,
    DeviceInfo deviceInfo,
    DiaryListThemeColors colors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildContentContainer(
            diary.content,
            dateString,
            deviceInfo,
            colors,
            showDate: true,
            diary: diary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeContainer(
    String timeString,
    DeviceInfo deviceInfo,
    DiaryListThemeColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(DiaryListViewConstants.bubblePadding),
      decoration: _buildContainerDecoration(colors),
      child: Text(
        timeString,
        style: TextStyle(
          color: colors.timeColor,
          fontSize: deviceInfo.fontSize * 0.5,
          fontFamily: deviceInfo.font,
        ),
      ),
    );
  }

  Widget _buildContentContainer(
    String content,
    String? dateString,
    DeviceInfo deviceInfo,
    DiaryListThemeColors colors, {
    required bool showDate,
    Diary? diary,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DiaryListViewConstants.bubblePadding,
        DiaryListViewConstants.bubblePadding,
        0,
        0,
      ),
      decoration: _buildContainerDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: TextStyle(
              color: colors.textColor,
              fontSize: deviceInfo.fontSize * 0.85,
              fontFamily: deviceInfo.font,
              height: deviceInfo.lineHeight,
              letterSpacing: deviceInfo.letterSpacing,
            ),
          ),
          if (showDate && dateString != null && diary != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  dateString,
                  style: TextStyle(
                    color: colors.dateColor,
                    fontSize: deviceInfo.fontSize * 0.6,
                    fontFamily: deviceInfo.font,
                  ),
                ),
                FavoriteButton(
                  diary: diary,
                  onToggleFavorite: onToggleFavorite,
                  favoriteColor: colors.favoriteColor,
                  favoriteBorderColor: colors.favoriteBorderColor,
                  iconPadding: DiaryListViewConstants.iconPadding,
                  fontSize: deviceInfo.fontSize,
                ),
              ],
            ),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(DiaryListThemeColors colors) {
    return BoxDecoration(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(DiaryListViewConstants.borderRadius),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 2),
          blurRadius: 5,
        ),
      ],
    );
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