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

  List<Diary> _filterDiaries(List<Diary> diaries) {
    List<Diary> filteredDiaries = diaries;
    if (_showFavoritesOnly) {
      filteredDiaries = filteredDiaries.where((diary) => diary.isFavorite).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredDiaries = filteredDiaries.where((diary) {
        final titleMatch = diary.title.toLowerCase().contains(query);
        final contentMatch = diary.content.toLowerCase().contains(query);
        final tagsMatch = diary.tags.any((tag) => tag.toLowerCase().contains(query));
        return titleMatch || contentMatch || tagsMatch;
      }).toList();
    }
    return filteredDiaries;
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
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Color(0xFFFE91A1) : Color(0xFF888888),
            ),
            onPressed: _toggleShowFavorites,
          ),
        ],
      ),
      body: FutureBuilder<List<Diary>>(
        future: _diaryList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFE91A1)));
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'まだ日記がありません',
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
