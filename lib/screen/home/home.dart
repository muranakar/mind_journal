import 'package:flutter/material.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/provider/deviceInfo.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:provider/provider.dart';

// 定数の定義
const double paddingHorizontal = 5.0;
const double paddingTop = 100.0;
const double tagContainerHeight = 40.0;
const double recommendedTagsContainerHeight = 300.0;
const double iconButtonSpacing = 16.0;
const double floatingActionButtonTop = 50.0;
const double floatingActionButtonRight = 10.0;
const double formFieldSpacing = 16.0;

const Color selectedIconColor = Color(0xFF81C784);
const Color floatingActionButtonColor = Color(0xFF81C784);

class HomeScreen extends StatefulWidget {
  final Function(int) onTabSelected; // タブのインデックスを変更するためのコールバック関数

  const HomeScreen(
      {super.key, required this.onTabSelected}); // コンストラクタでコールバック関数を受け取る

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _content = '';
  final List<String> _tags = [];
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
    final tags = await DiaryDatabase.instance.fetchAllTagsSortedByUsage();
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
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  paddingHorizontal, paddingTop, paddingHorizontal, 5.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '今の気持ちを記録しよう',
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
                          return '記録してほしいなぁ👀';
                        }
                        return null;
                      },
                      maxLines: 4,
                      autofocus: true,
                    ),
                    const SizedBox(height: formFieldSpacing),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              labelText: 'タグを追加',
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
                          icon: const Icon(Icons.add),
                          onPressed: () => _addTag(_tagController.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: tagContainerHeight,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _tags.map((tag) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Chip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                  fontFamily: deviceInfo.font,
                                  fontSize: deviceInfo.fontSize,
                                  letterSpacing: deviceInfo.letterSpacing,
                                  height: deviceInfo.lineHeight,
                                ),
                              ),
                              onDeleted: () => _removeTag(tag),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: formFieldSpacing),
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
                      const SizedBox(height: 8.0),
                      SizedBox(
                        height: recommendedTagsContainerHeight,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: _recommendedTags.map((tag) {
                              return GestureDetector(
                                onTap: () => _addTag(tag),
                                child: Chip(
                                  label: Text(
                                    tag,
                                    style: TextStyle(
                                      fontFamily: deviceInfo.font,
                                      fontSize: deviceInfo.fontSize,
                                      letterSpacing: deviceInfo.letterSpacing,
                                      height: deviceInfo.lineHeight,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                    ],
                  ],
                ),
                ),
              ),
            ),
            Positioned(
              top: floatingActionButtonTop,
              right: floatingActionButtonRight,
              child: FloatingActionButton.small(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Diary newDiary = Diary(
                      title: '',
                      content: _content,
                      isFavorite: false,
                      tags: _tags.toList(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      emotionImage: _emotion,
                    );

                    DiaryDatabase.instance.createDiary(newDiary);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('今の気持ちを記録しました📝')),
                    );

                    setState(() {
                      _content = '';
                      _tags.clear();
                      _emotion = '';
                      _selectedEmotion = '';
                      _formKey.currentState!.reset();
                      _tagController.clear();
                    });

                    widget.onTabSelected(1);
                  }
                },
                backgroundColor: floatingActionButtonColor,
                child: Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
