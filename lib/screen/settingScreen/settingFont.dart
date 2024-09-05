import 'package:flutter/material.dart';
import 'package:mind_journal/provider/deviceInfo.dart';
import 'package:provider/provider.dart';

class FontSelectionScreen extends StatefulWidget {
  @override
  _FontSelectionScreenState createState() => _FontSelectionScreenState();
}

class _FontSelectionScreenState extends State<FontSelectionScreen> {
  String? _selectedFont;
  double _selectedFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    final deviceInfo = Provider.of<DeviceInfo>(context, listen: false);
    _selectedFont = deviceInfo.font;
    _selectedFontSize = deviceInfo.fontSize;
  }

  static const String displayText = 'サンプルテキスト';

  final List<String> fonts = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フォントを選択', style: TextStyle(fontFamily: _selectedFont)),
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
                    '${index + 1}}' + 'あいうえおアイウエオ朝昼夜',
                    style: TextStyle(
                      fontFamily: font,
                      fontSize: _selectedFontSize,
                    ),
                  ),
                  value: font,
                  groupValue: _selectedFont,
                  onChanged: (value) {
                    setState(() {
                      _selectedFont = value;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('フォントサイズ: ${_selectedFontSize.toStringAsFixed(1)}'),
                Slider(
                  value: _selectedFontSize,
                  min: 10.0,
                  max: 30.0,
                  divisions: 20,
                  label: _selectedFontSize.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _selectedFontSize = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedFont != null) {
                      final deviceInfo =
                          Provider.of<DeviceInfo>(context, listen: false);
                      await deviceInfo.setFont(_selectedFont!);
                      await deviceInfo.setFontSize(_selectedFontSize);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('決定'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
