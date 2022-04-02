import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:json_buddy/global.dart';
import 'package:json_buddy/main.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback onCodeThemeChange;
  const SettingsDialog({required this.onCodeThemeChange, Key? key})
      : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool darkThemeActive;
  late String selectedCodeTheme;
  late int selectedCodeIndent;
  final List<DropdownMenuItem<String>> codeThemes = [];
  List<DropdownMenuItem<int>> identItems = [
    const DropdownMenuItem<int>(
      value: 2,
      child: Text('2'),
    ),
    const DropdownMenuItem<int>(
      value: 4,
      child: Text('4'),
    ),
    const DropdownMenuItem<int>(
      value: 6,
      child: Text('6'),
    ),
    const DropdownMenuItem<int>(
      value: 8,
      child: Text('8'),
    )
  ];

  @override
  void initState() {
    darkThemeActive = prefs.getBool(settingUseDarkTheme) ?? true;
    codeThemes.addAll(
      themeMap.keys
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e),
              value: e,
            ),
          )
          .toList(),
    );
    selectedCodeTheme = prefs.getString(settingCodeTheme) ?? "vs";
    selectedCodeIndent = prefs.getInt(settingIndent) ?? 2;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          leading: const Icon(
            Icons.desktop_windows_rounded,
          ),
          title: const Text('Use dark theme'),
          subtitle: Switch(
              value: darkThemeActive,
              onChanged: (newValue) {
                setState(() {
                  darkThemeActive = newValue;
                });
                prefs.setBool(settingUseDarkTheme, darkThemeActive);
                MyApp.of(context).changeTheme();
              }),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Code theme'),
          subtitle: DropdownButton(
            value: selectedCodeTheme,
            items: codeThemes,
            isExpanded: true,
            onChanged: (String? nextSelectedCodeTheme) {
              setState(() {
                selectedCodeTheme = nextSelectedCodeTheme ?? "vs";
              });
              prefs
                  .setString(settingCodeTheme, selectedCodeTheme)
                  .then((value) => widget.onCodeThemeChange());
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.text_rotation_none),
          title: const Text('JSON indent'),
          subtitle: DropdownButton(
            isExpanded: true,
            value: selectedCodeIndent,
            items: identItems,
            onChanged: (int? selectedIndent) {
              setState(() {
                selectedCodeIndent = selectedIndent ?? 2;
              });
              prefs
                  .setInt(settingIndent, selectedCodeIndent)
                  .then((value) => widget.onCodeThemeChange());
            },
          ),
        ),
      ],
    );
  }
}
