import 'package:flutter/material.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/screen/component/DiaryListView.dart';
import 'package:mind_journal/screen/tag/tagSearchResultList.dart';

class TagSearchScreen extends StatefulWidget {
  const TagSearchScreen({super.key});

  @override
  _TagSearchScreenState createState() => _TagSearchScreenState();
}

class _TagSearchScreenState extends State<TagSearchScreen> {
  late Future<List<Map<String, dynamic>>> _tagList;
  final List<String> _selectedTags = [];
  // キーを追加して強制的に再描画できるようにする
  final GlobalKey _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _tagList = DiaryDatabase.instance.fetchAllMapTagsSortedByUsage();
    _selectedTags.clear();
  }

  // 画面を完全にリセットする関数
  void _resetScreen() {
    setState(() {
      _initializeData();
    });
  }

  void _toggleTagSelection(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<List<Diary>> _searchDiariesByTags() async {
    return await DiaryDatabase.instance.filterDiariesBySelectedTags(_selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _refreshKey,
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () async {
              final filteredDiaries = await _searchDiariesByTags();
              if (!mounted) return;
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TagFilteredDiaryListScreen(
                    selectedTags: _selectedTags,
                  ),
                ),
              ).then((_) {
                // 画面を完全にリセット
                _resetScreen();
              });
            },
            child: const Text('記録を検索'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _tagList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('タグがありません'));
                }

                final tags = snapshot.data!;

                return Wrap(
                  spacing: 8.0,
                  children: tags
                      .where((tagData) =>
                          (tagData['count'] is int) && (tagData['count'] > 0))
                      .map((tagData) {
                    final tagName = tagData['name'];
                    final tagCount = tagData['count'] as int;
                    final isSelected = _selectedTags.contains(tagName);

                    return FilterChip(
                      label: Text('$tagName ($tagCount)'),
                      selected: isSelected,
                      onSelected: (selected) {
                        _toggleTagSelection(tagName);
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}