import 'package:flutter/material.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';

class FavoriteDiaryListScreen extends StatefulWidget {
  @override
  _FavoriteDiaryListScreenState createState() => _FavoriteDiaryListScreenState();
}

class _FavoriteDiaryListScreenState extends State<FavoriteDiaryListScreen> {
  late Future<List<Diary>> _favoriteDiaries;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _favoriteDiaries = _loadFavoriteDiaries();
  }

  Future<List<Diary>> _loadFavoriteDiaries() async {
    final allDiaries = await DiaryDatabase.instance.readAllDiaries();
    return allDiaries.where((diary) => diary.isFavorite).toList();
  }

  Future<void> _toggleFavorite(Diary diary) async {
    diary.isFavorite = !diary.isFavorite;
    await DiaryDatabase.instance.updateDiary(diary);
    setState(() {
      _favoriteDiaries = _loadFavoriteDiaries();
    });
  }

  Future<void> _deleteDiary(int id) async {
    await DiaryDatabase.instance.deleteDiary(id);
    setState(() {
      _favoriteDiaries = _loadFavoriteDiaries();
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Diary> _filterDiaries(List<Diary> diaries) {
    if (_searchQuery.isEmpty) {
      return diaries;
    }
    return diaries.where((diary) {
      final query = _searchQuery.toLowerCase();
      final titleMatch = diary.title.toLowerCase().contains(query);
      final contentMatch = diary.content.toLowerCase().contains(query);
      final tagsMatch = diary.tags.any((tag) => tag.toLowerCase().contains(query));
      return titleMatch || contentMatch || tagsMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF333333)),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'キーワード検索できます🔍',
            border: InputBorder.none,
          ),
          onChanged: _updateSearchQuery,
        ),
      ),
      body: FutureBuilder<List<Diary>>(
        future: _favoriteDiaries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFE91A1)));
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'お気に入りの日記がありません',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF888888),
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
