import 'package:flutter/material.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';

class TagSearchScreen extends StatefulWidget {
  const TagSearchScreen({super.key});

  @override
  _TagSearchScreenState createState() => _TagSearchScreenState();
}

class _TagSearchScreenState extends State<TagSearchScreen> {
  late Future<List<String>> _tagList; // タグのリストを保持
  final List<String> _selectedTags = []; // 選択されたタグ

  @override
  void initState() {
    super.initState();
    _tagList = DiaryDatabase.instance.fetchAllTagsSortedByUsage(); // タグを取得
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

  Future<List<Diary>> _filterDiariesByTags() async {
    final diaries = await DiaryDatabase.instance.readAllDiaries();
    if (_selectedTags.isEmpty) return diaries; // タグが選択されていなければ全て返す

    return diaries.where((diary) {
      return diary.tags.any((tag) => _selectedTags.contains(tag));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タグで検索'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder<List<String>>(
            future: _tagList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('タグがありません'));
              }

              final tags = snapshot.data!;

              return Wrap(
                spacing: 8.0,
                children: tags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      _toggleTagSelection(tag);
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final filteredDiaries = await _filterDiariesByTags();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TagFilteredDiaryListScreen(
                    filteredDiaries: filteredDiaries,
                  ),
                ),
              );
            },
            child: const Text('日記を検索'),
          ),
        ],
      ),
    );
  }
}

class TagFilteredDiaryListScreen extends StatelessWidget {
  final List<Diary> filteredDiaries;

  const TagFilteredDiaryListScreen({super.key, required this.filteredDiaries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索結果'),
        centerTitle: true,
      ),
      body: filteredDiaries.isEmpty
          ? const Center(child: Text('該当する日記がありません'))
          : ListView.builder(
              itemCount: filteredDiaries.length,
              itemBuilder: (context, index) {
                final diary = filteredDiaries[index];
                return ListTile(
                  title: Text(diary.title),
                  subtitle: Text(diary.content),
                );
              },
            ),
    );
  }
}
