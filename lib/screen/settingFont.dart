import 'package:flutter/material.dart';

class FontSelectionScreen extends StatelessWidget {
  final String selectedFont;
  final ValueChanged<String> onFontSelected;

  FontSelectionScreen({required this.selectedFont, required this.onFontSelected});

  // 定数で表示する文字を定義
  static const String displayText = 'サンプルテキスト';

  @override
  Widget build(BuildContext context) {
    final fonts = [
      'Buildingsandundertherailwaytracks-Regular',
      
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('フォントを選択', style: TextStyle(fontFamily: selectedFont)),
      ),
      body: ListView.builder(
        itemCount: fonts.length,
        itemBuilder: (context, index) {
          final font = fonts[index];
          return RadioListTile<String>(
            title: Text(
              displayText,
              style: TextStyle(fontFamily: font), // ここでフォントを適用
            ),
            value: font,
            groupValue: selectedFont,
            onChanged: (value) {
              if (value != null) {
                onFontSelected(value);
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }
}
