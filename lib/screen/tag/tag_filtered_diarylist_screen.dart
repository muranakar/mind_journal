
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';
import 'package:mind_journal/screen/tag/tagSearch.dart';

class TagFilteredDiaryListScreen extends ConsumerWidget {
  const TagFilteredDiaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);
    final diariesAsync = ref.watch(filteredDiariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('検索結果: ${selectedTags.join(", ")}'),
      ),
      body: diariesAsync.when(
        data: (diaries) {
          if (diaries.isEmpty) {
            return const Center(child: Text('該当する日記がありません'));
          }
          return DiaryListView(
            diaries: diaries,
            onToggleFavorite: (diary) async {
              await ref.read(diariesProvider.notifier).toggleFavorite(diary);
            },
            onDeleteDiary: (id) async {
              await ref.read(diariesProvider.notifier).deleteDiary(id);
              Navigator.pop(context); // 削除後に前の画面に戻る
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラー: $error')),
      ),
    );
  }
}
