import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import './diary.dart';

class DiaryNotifier extends StateNotifier<List<Diary>> {
  final DiaryDatabase _database;

  DiaryNotifier(this._database) : super([]) {
    // 初期化時に日記を読み込む
    loadDiaries();
  }

  Future<void> loadDiaries() async {
    state = await _database.readAllDiaries();
  }

  Future<void> addDiary(Diary diary) async {
    final id = await _database.createDiary(diary);
    final newDiary = diary.copyWith(id: id);
    state = [...state, newDiary];
  }

  Future<void> updateDiary(Diary diary) async {
    await _database.updateDiary(diary);
    state = state.map((d) => d.id == diary.id ? diary : d).toList();
  }

  Future<void> deleteDiary(int id) async {
    await _database.deleteDiary(id);
    state = state.where((diary) => diary.id != id).toList();
  }

  Future<List<Diary>> searchDiaries(String keyword) async {
    return await _database.searchDiaries(keyword);
  }

  Future<List<Diary>> getDiariesByTags(List<String> tags) async {
    return await _database.getDiariesByTags(tags);
  }

  // お気に入りの切り替え
  Future<void> toggleFavorite(Diary diary) async {
    final updatedDiary = diary.copyWith(isFavorite: !diary.isFavorite);
    await updateDiary(updatedDiary);
  }

  // 日付でフィルター
  List<Diary> getDiariesForDate(DateTime date) {
    return state.where((diary) {
      final diaryDate = diary.createdAt;
      return diaryDate.year == date.year && 
             diaryDate.month == date.month && 
             diaryDate.day == date.day;
    }).toList();
  }

  // お気に入りのみを取得
  List<Diary> getFavoriteDiaries() {
    return state.where((diary) => diary.isFavorite).toList();
  }

  // 日記を作成日時でソート
  void sortByDate({bool descending = true}) {
    state = [...state]..sort((a, b) => descending
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
  }

  // キーワードで検索（ローカル）
  List<Diary> searchLocal(String keyword) {
    if (keyword.isEmpty) return state;
    
    final query = keyword.toLowerCase();
    return state.where((diary) {
      return diary.title.toLowerCase().contains(query) ||
             diary.content.toLowerCase().contains(query) ||
             diary.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  // 特定の期間の日記を取得
  List<Diary> getDiariesInRange(DateTime start, DateTime end) {
    return state.where((diary) {
      return diary.createdAt.isAfter(start) && 
             diary.createdAt.isBefore(end);
    }).toList();
  }
}

// 必要に応じて追加のプロバイダーを定義
final filteredDiariesProvider = Provider<List<Diary>>((ref) {
  final allDiaries = ref.watch(diariesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final showFavorites = ref.watch(showFavoritesOnlyProvider);

  // 検索とフィルタリングを適用
  return allDiaries.where((diary) {
    if (showFavorites && !diary.isFavorite) return false;
    if (searchQuery.isEmpty) return true;
    
    final query = searchQuery.toLowerCase();
    return diary.title.toLowerCase().contains(query) ||
           diary.content.toLowerCase().contains(query) ||
           diary.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});

// 日記の検索状態を管理するプロバイダー
final searchQueryProvider = StateProvider<String>((ref) => '');

// お気に入りフィルターの状態を管理するプロバイダー
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

// 選択された日付の日記を提供するプロバイダー
final selectedDateDiariesProvider = Provider<List<Diary>>((ref) {
  final allDiaries = ref.watch(diariesProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  return allDiaries.where((diary) {
    final diaryDate = diary.createdAt;
    return diaryDate.year == selectedDate.year &&
           diaryDate.month == selectedDate.month &&
           diaryDate.day == selectedDate.day;
  }).toList();
});

// 選択された日付を管理するプロバイダー
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());