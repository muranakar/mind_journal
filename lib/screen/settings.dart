import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedFont = 'Roboto';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedFont = prefs.getString('selectedFont') ?? 'Roboto';
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('isDarkMode', value);
    });
  }

  Future<void> _changeFont(String font) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFont = font;
      prefs.setString('selectedFont', font);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定', style: TextStyle(fontFamily: _selectedFont)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text('ダークモード', style: TextStyle(fontFamily: _selectedFont)),
            value: _isDarkMode,
            onChanged: (value) {
              _toggleDarkMode(value);
            },
          ),
          ListTile(
            title: Text('フォント設定', style: TextStyle(fontFamily: _selectedFont)),
            subtitle: Text('現在のフォント: $_selectedFont'),
            onTap: () => _showFontDialog(context),
          ),
        ],
      ),
    );
  }

  void _showFontDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('フォントを選択', style: TextStyle(fontFamily: _selectedFont)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFontOption(context, 'Roboto'),
              _buildFontOption(context, 'Cursive'),
              _buildFontOption(context, 'Monospace'),
              _buildFontOption(context, 'Serif'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('キャンセル', style: TextStyle(color: Colors.red, fontFamily: _selectedFont)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontOption(BuildContext context, String font) {
    return RadioListTile<String>(
      title: Text(font, style: TextStyle(fontFamily: font)),
      value: font,
      groupValue: _selectedFont,
      onChanged: (value) {
        if (value != null) {
          _changeFont(value);
          Navigator.of(context).pop();
        }
      },
    );
  }
}
