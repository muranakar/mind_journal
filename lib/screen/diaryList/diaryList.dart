import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';


// 定数の定義
const Color appBarIconColor = Color(0xFF333333);
const Color searchHintColor = Color(0xFF888888);
const Color favoriteIconColorActive = Color(0xFFFE91A1);
const Color favoriteIconColorInactive = Color(0xFF888888);
const double appBarElevation = 0.0;
const double appBarFontSize = 18.0;

// 検索クエリを管理するプロバイダー
final searchQueryProvider = StateProvider<String>((ref) => '');

// お気に入りフィルターを管理するプロバイダー
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

// ソート順を管理するプロバイダー
final isDescendingProvider = StateProvider<bool>((ref) => true);

// フィルター済みの日記リストを提供するプロバイダー
final filteredDiariesProvider = Provider<List<Diary>>((ref) {
  final diaries = ref.watch(diariesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
  final isDescending = ref.watch(isDescendingProvider);

  List<Diary> filteredDiaries = diaries;

  // お気に入りフィルター
  if (showFavoritesOnly) {
    filteredDiaries = filteredDiaries.where((diary) => diary.isFavorite).toList();
  }

  // 検索クエリによるフィルター
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filteredDiaries = filteredDiaries.where((diary) {
      final titleMatch = diary.title.toLowerCase().contains(query);
      final contentMatch = diary.content.toLowerCase().contains(query);
      final tagsMatch = diary.tags.any((tag) => tag.toLowerCase().contains(query));
      return titleMatch || contentMatch || tagsMatch;
    }).toList();
  }

  // ソート
  filteredDiaries.sort((a, b) => isDescending
      ? b.createdAt.compareTo(a.createdAt)
      : a.createdAt.compareTo(b.createdAt));

  return filteredDiaries;
});

class DiaryListScreen extends ConsumerWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredDiaries = ref.watch(filteredDiariesProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final isDescending = ref.watch(isDescendingProvider);
    final diaryNotifier = ref.watch(diariesProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: appBarElevation,
          centerTitle: true,
          iconTheme: const IconThemeData(color: appBarIconColor),
          title: TextField(
            decoration: const InputDecoration(
              hintText: 'キーワード検索できます🔍',
              border: InputBorder.none,
              hintStyle: TextStyle(color: searchHintColor),
            ),
            onChanged: (query) {
              ref.read(searchQueryProvider.notifier).state = query;
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                color: showFavoritesOnly
                    ? favoriteIconColorActive
                    : favoriteIconColorInactive,
              ),
              onPressed: () {
                ref.read(showFavoritesOnlyProvider.notifier).update((state) => !state);
              },
            ),
            IconButton(
              icon: Icon(
                isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                color: appBarIconColor,
              ),
              onPressed: () {
                ref.read(isDescendingProvider.notifier).update((state) => !state);
              },
            ),
          ],
        ),
        body: filteredDiaries.isEmpty
            ? const Center(
                child: Text(
                  'まだ日記がありません',
                  style: TextStyle(
                    fontSize: appBarFontSize,
                    color: searchHintColor,
                  ),
                ),
              )
            : DiaryListView(
                diaries: filteredDiaries,
                onToggleFavorite: (diary) async {
                  await diaryNotifier.updateDiary(
                    diary.copyWith(isFavorite: !diary.isFavorite),
                  );
                },
                onDeleteDiary: (id) async {
                  await diaryNotifier.deleteDiary(id);
                },
              ),
      ),
    );
  }
}