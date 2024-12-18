import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/main.dart';
import 'package:mind_journal/model/diary.dart';


final tagUsageRefreshProvider = StateProvider<int>((ref) => 0);

final selectedTagsProvider =
    StateNotifierProvider<SelectedTagsNotifier, List<String>>(
  (ref) => SelectedTagsNotifier(),
);

class SelectedTagsNotifier extends StateNotifier<List<String>> {
  SelectedTagsNotifier() : super([]);

  void toggleTag(String tag) {
    if (state.contains(tag)) {
      state = state.where((t) => t != tag).toList();
    } else {
      state = [...state, tag];
    }
  }

  void clear() {
    state = [];
  }
}


final filteredDiariesProvider = FutureProvider<List<Diary>>((ref) {
  final selectedTags = ref.watch(selectedTagsProvider);
  if (selectedTags.isEmpty) return [];

  // keepAliveを有効化
  ref.keepAlive();

  final database = ref.watch(diaryDatabaseProvider);
  return database.filterDiariesBySelectedTags(selectedTags);
});

class TagSearchScreen extends ConsumerWidget {
  const TagSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tagUsageRefreshProvider); // 画面表示のたびにリフレッシュ
    final selectedTags = ref.watch(selectedTagsProvider);
    final tagUsage = ref.watch(tagUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('タグ検索'),
        actions: [
          if (selectedTags.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.tagFilteredList);
              },
              child: const Text('記録を検索'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: tagUsage.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return const Center(child: Text('タグがありません'));
                }
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: tags
                      .where((tagData) =>
                          (tagData['count'] is int) && (tagData['count'] > 0))
                      .map((tagData) {
                    final tagName = tagData['name'] as String;
                    final tagCount = tagData['count'] as int;
                    final isSelected = selectedTags.contains(tagName);

                    return FilterChip(
                      label: Text('$tagName ($tagCount)'),
                      selected: isSelected,
                      onSelected: (_) {
                        ref
                            .read(selectedTagsProvider.notifier)
                            .toggleTag(tagName);
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('エラー: $error')),
            ),
          ),
          if (selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  const Text('選択中のタグ: '),
                  ...selectedTags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          ref
                              .read(selectedTagsProvider.notifier)
                              .toggleTag(tag);
                        },
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
