import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/main.dart';

// フォントのリスト
final fonts = [
  'HannariMincho',
  'KiwiMaru',
  'TsukimiRounded',
  'ShipporiMincho',
  'ZenKurenaido', 
  'KleeOne',
  'Yomogi',
  'KaiseiTokumin',
  'KosugiMaru',
  'YujiSyuku',
  'Buildingsandundertherailwaytracks',
  'RocknRollOne',
  'DarumadropOne',
  'HachiMaruPop',
  'Stick',
  'MonomaniacOne',
  'YuseiMagic',
  'SlacksideOne',
];

class FontSelectionScreen extends ConsumerStatefulWidget {
  const FontSelectionScreen({super.key});

  @override
  ConsumerState<FontSelectionScreen> createState() => _FontSelectionScreenState();
}

class _FontSelectionScreenState extends ConsumerState<FontSelectionScreen> {
  static const String displayText = 'サンプルテキスト';

  @override
  Widget build(BuildContext context) {
    final deviceInfo = ref.watch(deviceInfoProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'フォントを選択',
          style: TextStyle(fontFamily: deviceInfo.font),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: fonts.length,
              itemBuilder: (context, index) {
                final font = fonts[index];
                return RadioListTile<String>(
                  title: Text(
                    'あいうえおアイウエオ朝昼夜',
                    style: TextStyle(
                      fontFamily: font,
                      fontSize: deviceInfo.fontSize,
                    ),
                  ),
                  value: font,
                  groupValue: deviceInfo.font,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(deviceInfoProvider.notifier).updateFont(value);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'フォントサイズ: ${deviceInfo.fontSize.toStringAsFixed(1)}',
                  style: TextStyle(fontFamily: deviceInfo.font),
                ),
                Slider(
                  value: deviceInfo.fontSize,
                  min: 10.0,
                  max: 20.0,
                  divisions: 10,
                  label: deviceInfo.fontSize.toStringAsFixed(1),
                  onChanged: (value) {
                    ref.read(deviceInfoProvider.notifier).updateFontSize(value);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// プレビューテキストのスタイルを提供するプロバイダー
final previewTextStyleProvider = Provider<TextStyle>((ref) {
  final deviceInfo = ref.watch(deviceInfoProvider);
  return TextStyle(
    fontFamily: deviceInfo.font,
    fontSize: deviceInfo.fontSize,
    letterSpacing: deviceInfo.letterSpacing,
    height: deviceInfo.lineHeight,
  );
});