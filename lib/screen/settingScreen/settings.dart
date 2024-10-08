import 'package:flutter/material.dart';
import 'package:mind_journal/provider/deviceInfo.dart';
import 'package:mind_journal/screen/settingScreen/settingFont.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<DeviceInfo>(context, listen: false).loadSettings(); // 初期設定の読み込み
  }

  @override
  Widget build(BuildContext context) {
    final deviceInfo = Provider.of<DeviceInfo>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('設定', style: TextStyle(fontFamily: deviceInfo.font)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title:
                Text('ダークモード', style: TextStyle(fontFamily: deviceInfo.font)),
            value: deviceInfo.isDarkMode,
            onChanged: (value) {
              deviceInfo.toggleDarkMode(value);
            },
          ),
          ListTile(
            title:
                Text('フォント設定', style: TextStyle(fontFamily: deviceInfo.font)),
            subtitle: Text('現在のフォント: ${deviceInfo.font}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FontSelectionScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
