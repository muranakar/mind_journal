import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/provider/deviceInfo.dart';

class DiaryEditScreen extends StatefulWidget {
  final Diary diary;
  final Function(Diary) onSave;

  const DiaryEditScreen({super.key, required this.diary, required this.onSave});

  @override
  _DiaryEditScreenState createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> _tags;
  late String _selectedEmotion;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.diary.title);
    _contentController = TextEditingController(text: widget.diary.content);
    _tags = List.from(widget.diary.tags);
    _selectedEmotion = widget.diary.emotionImage;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceInfo>(
      builder: (context, deviceInfo, child) {
        final isDarkMode = deviceInfo.isDarkMode;
        final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
        final accentColor = isDarkMode ? const Color(0xFFFE91A1) : const Color(0xFFFE91A1);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: Text(
              'Edit Diary',
              style: TextStyle(color: textColor, fontFamily: deviceInfo.font),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.check, color: accentColor),
                onPressed: () {
                  final updatedDiary = widget.diary.copyWith(
                    title: _titleController.text,
                    content: _contentController.text,
                    tags: _tags,
                    updatedAt: DateTime.now(),
                    emotionImage: _selectedEmotion,
                  );
                  widget.onSave(updatedDiary);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    color: textColor,
                    fontSize: deviceInfo.fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    fontFamily: deviceInfo.font,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  style: TextStyle(
                    color: textColor,
                    fontSize: deviceInfo.fontSize,
                    fontFamily: deviceInfo.font,
                    height: deviceInfo.lineHeight,
                    letterSpacing: deviceInfo.letterSpacing,
                  ),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tags',
                  style: TextStyle(
                    color: textColor,
                    fontSize: deviceInfo.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: deviceInfo.font,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          _tags.remove(tag);
                        });
                      },
                    )),
                    ActionChip(
                      label: Icon(Icons.add),
                      onPressed: () async {
                        final newTag = await showDialog<String>(
                          context: context,
                          builder: (context) => _AddTagDialog(),
                        );
                        if (newTag != null && newTag.isNotEmpty) {
                          setState(() {
                            _tags.add(newTag);
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Emotion',
                  style: TextStyle(
                    color: textColor,
                    fontSize: deviceInfo.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: deviceInfo.font,
                  ),
                ),
                SizedBox(height: 8),
                _buildEmotionSelector(deviceInfo),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmotionSelector(DeviceInfo deviceInfo) {
    final emotions = [
      'assets/emotions/happy.png',
      'assets/emotions/sad.png',
      'assets/emotions/angry.png',
      'assets/emotions/excited.png',
      'assets/emotions/neutral.png',
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: emotions.map((emotion) {
        final isSelected = _selectedEmotion == emotion;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedEmotion = emotion;
            });
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              emotion,
              width: deviceInfo.fontSize * 2,
              height: deviceInfo.fontSize * 2,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AddTagDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Tag'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Enter tag'),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}