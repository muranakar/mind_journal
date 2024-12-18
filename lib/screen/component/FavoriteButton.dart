import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';

class FavoriteButton extends ConsumerWidget {
  final Diary diary;
  final Color favoriteColor;
  final Color favoriteBorderColor;
  final double iconPadding;
  final double fontSize;

  const FavoriteButton({
    super.key,
    required this.diary,
    required this.favoriteColor,
    required this.favoriteBorderColor,
    required this.iconPadding,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchDiary = ref.watch(diariesProvider
        .select((state) => state.firstWhere((d) => d.id == diary.id)));
    final isFavorite = ref.watch(diariesProvider.select(
        (state) => state.firstWhere((d) => d.id == diary.id).isFavorite));

    return Hero(
      tag: 'favorite_button_${diary.id}',
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? favoriteColor : favoriteBorderColor,
          size: fontSize * 0.85,
        ),
        onPressed: () async {
          await ref.read(diariesProvider.notifier).toggleFavorite(watchDiary);
        },
        padding: EdgeInsets.all(iconPadding),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
