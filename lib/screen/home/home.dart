import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/provider/deviceInfo.dart';

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

// 状態管理用のプロバイダー群
final contentProvider = StateProvider<String>((ref) => '');
final tagsProvider = StateNotifierProvider<TagsNotifier, List<String>>((ref) => TagsNotifier());
final tagControllerProvider = Provider((ref) => TextEditingController());
final recommendedTagsProvider = StateNotifierProvider<RecommendedTagsNotifier, List<String>>(
  (ref) => RecommendedTagsNotifier(ref),
);

// タグ管理用のNotifier
class TagsNotifier extends StateNotifier<List<String>> {
  TagsNotifier() : super([]);

  void addTag(String tag) {
    if (tag.isNotEmpty && !state.contains(tag)) {
      state = [...state, tag];
    }
  }

  void removeTag(String tag) {
    state = state.where((t) => t != tag).toList();
  }

  void clear() {
    state = [];
  }
}

// おすすめタグ管理用のNotifier
class RecommendedTagsNotifier extends StateNotifier<List<String>> {
  final Ref _ref;
  
  RecommendedTagsNotifier(this._ref) : super([]) {
    loadRecommendedTags();
  }

  Future<void> loadRecommendedTags() async {
    final tags = await _ref.read(diaryDatabaseProvider).fetchAllTagsSortedByUsage();
    state = tags;
  }
}

// デバイス情報用のプロバイダー
final deviceInfoProvider = Provider((ref) => DeviceInfo());

class HomeScreen extends ConsumerWidget {
  final Function(int) onTabSelected;
  final _formKey = GlobalKey<FormState>();

  HomeScreen({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceInfo = ref.watch(deviceInfoProvider);
    final tags = ref.watch(tagsProvider);
    final recommendedTags = ref.watch(recommendedTagsProvider);
    final tagController = ref.watch(tagControllerProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                          ref.read(contentProvider.notifier).state = value ?? '';
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
                              controller: tagController,
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
                              onFieldSubmitted: (value) {
                                ref.read(tagsProvider.notifier).addTag(value);
                                tagController.clear();
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              ref.read(tagsProvider.notifier).addTag(tagController.text);
                              tagController.clear();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      _buildTagList(context, ref, tags, deviceInfo),
                      const SizedBox(height: formFieldSpacing),
                      if (recommendedTags.isNotEmpty)
                        _buildRecommendedTags(context, ref, recommendedTags, deviceInfo),
                    ],
                  ),
                ),
              ),
            ),
            _buildSubmitButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTagList(BuildContext context, WidgetRef ref, List<String> tags, DeviceInfo deviceInfo) {
    return SizedBox(
      height: tagContainerHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tags.map((tag) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
              onDeleted: () => ref.read(tagsProvider.notifier).removeTag(tag),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendedTags(BuildContext context, WidgetRef ref, List<String> recommendedTags, DeviceInfo deviceInfo) {
    return Column(
      children: [
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
              children: recommendedTags.map((tag) {
                return GestureDetector(
                  onTap: () => ref.read(tagsProvider.notifier).addTag(tag),
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
    );
  }

  Widget _buildSubmitButton(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: floatingActionButtonTop,
      right: floatingActionButtonRight,
      child: FloatingActionButton.small(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            final content = ref.read(contentProvider);
            final tags = ref.read(tagsProvider);

            final newDiary = Diary(
              title: '',
              content: content,
              isFavorite: false,
              tags: tags,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              emotionImage: '',
            );

            ref.read(diariesProvider.notifier).addDiary(newDiary);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('今の気持ちを記録しました📝')),
            );

            // 状態をリセット
            ref.read(contentProvider.notifier).state = '';
            ref.read(tagsProvider.notifier).clear();
            _formKey.currentState!.reset();
            ref.read(tagControllerProvider).clear();

            onTabSelected(1);
          }
        },
        backgroundColor: floatingActionButtonColor,
        child: const Icon(Icons.send),
      ),
    );
  }
}