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
  late Future<List<Map<String, dynamic>>> _tagList; // タグとその件数のリストを保持
  final List<String> _selectedTags = []; // 選択されたタグ

  @override
  void initState() {
    super.initState();
    _tagList = DiaryDatabase.instance.fetchAllMapTagsSortedByUsage(); // タグを取得
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
    return await DiaryDatabase.instance
        .filterDiariesBySelectedTags(_selectedTags); // タグに基づいて日記をフィルタリング
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
                onPressed: () async {
                  final filteredDiaries = await _searchDiariesByTags();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TagFilteredDiaryListScreen(
                        filteredDiaries: filteredDiaries,
                      ),
                    ),
                  );
                },
                child: const Text('記録を検索'),
              ),
        ],
      ),
      body: SingleChildScrollView(
        // スクロール可能にする
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
                  children: tags.map((tagData) {
                    final tagName = tagData['name'];
                    final tagCount = tagData['count'];
                    final isSelected = _selectedTags.contains(tagName);
                    return FilterChip(
                      label: Text('$tagName ($tagCount)'), // タグ名と件数を表示
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
