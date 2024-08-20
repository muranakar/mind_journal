import 'package:flutter/material.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/deviceInfo.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _content = '';
  List<String> _tags = [];
  String _emotion = '';
  String _selectedEmotion = '';
  List<String> _recommendedTags = [];

  final List<Map<String, dynamic>> moods = [
    {'icon': Icons.sentiment_very_satisfied, 'label': 'Very Satisfied'},
    {'icon': Icons.sentiment_satisfied, 'label': 'Satisfied'},
    {'icon': Icons.sentiment_neutral, 'label': 'Neutral'},
    {'icon': Icons.sentiment_dissatisfied, 'label': 'Dissatisfied'},
    {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Very Dissatisfied'},
  ];

  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecommendedTags();
  }

  void _loadRecommendedTags() async {
    final tags = await DiaryDatabase.instance.getAllTags();
    setState(() {
      _recommendedTags = tags;
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceInfo = Provider.of<DeviceInfo>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 60.0, 5.0, 5),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '内容',
                    labelStyle: TextStyle(
                      fontFamily: deviceInfo.font,
                      fontSize: deviceInfo.fontSize,
                      letterSpacing: deviceInfo.letterSpacing,
                      height: deviceInfo.lineHeight,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: deviceInfo.font,
                    fontSize: deviceInfo.fontSize,
                    letterSpacing: deviceInfo.letterSpacing,
                    height: deviceInfo.lineHeight,
                  ),
                  onSaved: (value) {
                    _content = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '内容を入力してください';
                    }
                    return null;
                  },
                  maxLines: 2,
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Text(
                      '気持ち:',
                      style: TextStyle(
                        fontFamily: deviceInfo.font,
                        fontSize: deviceInfo.fontSize,
                        letterSpacing: deviceInfo.letterSpacing,
                        height: deviceInfo.lineHeight,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    ...moods.map((mood) {
                      return IconButton(
                        icon: Icon(mood['icon']),
                        color: _selectedEmotion == mood['label']
                            ? const Color.fromARGB(255, 58, 214, 63)
                            : null,
                        onPressed: () {
                          setState(() {
                            _emotion = mood['label'];
                            _selectedEmotion = mood['label'];
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: 'タグを入力',
                          labelStyle: TextStyle(
                            fontFamily: deviceInfo.font,
                            fontSize: deviceInfo.fontSize,
                            letterSpacing: deviceInfo.letterSpacing,
                            height: deviceInfo.lineHeight,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: deviceInfo.font,
                          fontSize: deviceInfo.fontSize,
                          letterSpacing: deviceInfo.letterSpacing,
                          height: deviceInfo.lineHeight,
                        ),
                        onFieldSubmitted: (value) => _addTag(value),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addTag(_tagController.text),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 40.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _tags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.0),
                if (_recommendedTags.isNotEmpty) ...[
                  Text(
                    'おすすめタグ:',
                    style: TextStyle(
                      fontFamily: deviceInfo.font,
                      fontSize: deviceInfo.fontSize,
                      letterSpacing: deviceInfo.letterSpacing,
                      height: deviceInfo.lineHeight,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    height: 40.0,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _recommendedTags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () => _addTag(tag),
                            child: Chip(
                              label: Text(tag),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 8.0),
                ],
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      Diary newDiary = Diary(
                        title: '', // タイトルは空のまま
                        content: _content,
                        tags: _tags,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        emotionImage: _emotion,
                      );

                      await DiaryDatabase.instance.createDiary(newDiary);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('今の気持ちを記録しました📝')),
                      );

                      // フォームのリセット処理
                      setState(() {
                        _content = '';
                        _tags.clear();
                        _emotion = '';
                        _selectedEmotion = '';
                        _formKey.currentState!.reset();
                        _tagController.clear();
                      });
                    }
                  },
                  child: Text(
                    '保存',
                    style: TextStyle(
                      fontFamily: deviceInfo.font,
                      fontSize: deviceInfo.fontSize,
                      letterSpacing: deviceInfo.letterSpacing,
                      height: deviceInfo.lineHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
