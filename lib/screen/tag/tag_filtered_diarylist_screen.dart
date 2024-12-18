import 'package:flutter/material.dart';
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
      body: selectedTags.isEmpty
          ? const Center(child: Text('タグを選択してください'))
          : diariesAsync.when(
              data: (diaries) {
                if (diaries.isEmpty) {
                  return const Center(child: Text('該当する日記がありません'));
                }
                return DiaryListView(
                  diaries: diaries,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('エラー: $error')),
            ),
    );
  }
}
