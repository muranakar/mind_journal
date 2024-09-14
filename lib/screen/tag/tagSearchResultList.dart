import 'package:flutter/material.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';

class TagFilteredDiaryListScreen extends StatefulWidget {
  final List<String> selectedTags;

  const TagFilteredDiaryListScreen({
    Key? key,
    required this.selectedTags,
  }) : super(key: key);

  @override
  _TagFilteredDiaryListScreenState createState() =>
      _TagFilteredDiaryListScreenState();
}

class _TagFilteredDiaryListScreenState
    extends State<TagFilteredDiaryListScreen> {
  late List<Diary> _diaryList = [];
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  bool _isDescending = true;
  List<String> _selectedTags = [];

  static const Color appBarIconColor = Color(0xFF333333);
  static const Color searchHintColor = Color(0xFF888888);
  static const Color favoriteIconColorActive = Color(0xFFFE91A1);
  static const Color favoriteIconColorInactive = Color(0xFF888888);
  static const double appBarElevation = 0.0;
  static const double appBarFontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final diaries = await DiaryDatabase.instance.getDiariesByTags(_selectedTags);
    setState(() {
      _diaryList = diaries;
    });
  }

  Future<void> _toggleFavorite(Diary diary) async {
    diary.isFavorite = !diary.isFavorite;
    await DiaryDatabase.instance.updateDiary(diary);
    await _loadDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await DiaryDatabase.instance.deleteDiary(id);
    await _loadDiaries();
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
    filteredDiaries.sort((a, b) => _isDescending
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return filteredDiaries;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
        body: Builder(
          builder: (context) {
            final filteredDiaries = _filterDiaries(_diaryList);

            if (filteredDiaries.isEmpty) {
              return const Center(
                child: Text(
                  'まだ日記がありません',
                  style: TextStyle(
                    fontSize: appBarFontSize,
                    color: searchHintColor,
                  ),
                ),
              );
            }

            return DiaryListView(
              diaries: filteredDiaries,
              onToggleFavorite: _toggleFavorite,
              onDeleteDiary: _deleteDiary,
            );
          },
        ),
      ),
    );
  }
}