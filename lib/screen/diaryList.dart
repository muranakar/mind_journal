import 'package:flutter/material.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';

class DiaryListScreen extends StatefulWidget {
  @override
  _DiaryListScreenState createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  late Future<List<Diary>> _diaryList;
  String _searchQuery = '';
  bool _showFavoritesOnly = false; // お気に入りのみ表示するかどうか
  bool _isDescending = true; // 昇順・降順の切り替え

  // 定数の宣言
  static const Color appBarIconColor = Color(0xFF333333);
  static const Color searchHintColor = Color(0xFF888888);
  static const Color favoriteIconColorActive = Color(0xFFFE91A1);
  static const Color favoriteIconColorInactive = Color(0xFF888888);
  static const double appBarElevation = 0.0;
  static const double appBarFontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _diaryList = DiaryDatabase.instance.readAllDiaries();
  }

  Future<void> _toggleFavorite(Diary diary) async {
    diary.isFavorite = !diary.isFavorite;
    await DiaryDatabase.instance.updateDiary(diary);
    setState(() {
      _diaryList = DiaryDatabase.instance.readAllDiaries();
    });
  }

  Future<void> _deleteDiary(int id) async {
    await DiaryDatabase.instance.deleteDiary(id);
    setState(() {
      _diaryList = DiaryDatabase.instance.readAllDiaries();
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _toggleShowFavorites() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  List<Diary> _filterDiaries(List<Diary> diaries) {
    List<Diary> filteredDiaries = diaries;
    if (_showFavoritesOnly) {
      filteredDiaries =
          filteredDiaries.where((diary) => diary.isFavorite).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredDiaries = filteredDiaries.where((diary) {
        final titleMatch = diary.title.toLowerCase().contains(query);
        final contentMatch = diary.content.toLowerCase().contains(query);
        final tagsMatch =
            diary.tags.any((tag) => tag.toLowerCase().contains(query));
        return titleMatch || contentMatch || tagsMatch;
      }).toList();
    }
    // 日記を昇順または降順に並び替える
    filteredDiaries.sort((a, b) => _isDescending
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return filteredDiaries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: appBarElevation,
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarIconColor),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'キーワード検索できます🔍',
            border: InputBorder.none,
            hintStyle: TextStyle(color: searchHintColor),
          ),
          onChanged: _updateSearchQuery,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly
                  ? favoriteIconColorActive
                  : favoriteIconColorInactive,
            ),
            onPressed: _toggleShowFavorites,
          ),
          IconButton(
            icon: Icon(
              _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
              color: appBarIconColor,
            ),
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      body: FutureBuilder<List<Diary>>(
        future: _diaryList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator(color: favoriteIconColorActive));
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'まだ日記がありません',
                style: TextStyle(
                  fontSize: appBarFontSize,
                  color: searchHintColor,
                ),
              ),
            );
          }

          final filteredDiaries = _filterDiaries(snapshot.data!);

          return DiaryListView(
            diaries: filteredDiaries,
            onToggleFavorite: _toggleFavorite,
            onDeleteDiary: _deleteDiary,
          );
        },
      ),
    );
  }
}
