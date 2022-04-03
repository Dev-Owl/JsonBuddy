import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl_standalone.dart';
import 'package:json_buddy/helper/global.dart';
import 'package:json_buddy/helper/globalization.dart';
import 'package:json_buddy/helper/short_cut_provider.dart';
import 'package:json_buddy/main_screen.dart';
import 'package:json_buddy/helper/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
    TODO: 
          - First start tutorial
          - Help screen, button to restart tutorial, explain shortcuts
          - Multiple languages
          - Code clean up
          - Create test cases
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  var sysLocal = await findSystemLocale();
  sysLocal = sysLocal.split("_").first.toLowerCase();
  if (valuesByLanguage.containsKey(sysLocal)) {
    GlobalConfig.currentLanguage = sysLocal;
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  /// Add an InheritedWidget-style static accessor so we can
  /// find our State object from any descendant & call changeTheme
  /// from anywhere.
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  late ThemeData themeToUse;

  @override
  void initState() {
    changeTheme(
      stateChange: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => GlobalConfig.shortCutProvider.triggerShortcut(
              JsonBuddyShortcut.search,
            ),
        const SingleActivator(
          LogicalKeyboardKey.enter,
          control: true,
        ): () => GlobalConfig.shortCutProvider.triggerShortcut(
              JsonBuddyShortcut.validateCode,
            ),
      },
      child: MaterialApp(
        title: 'JSON Buddy',
        debugShowCheckedModeBanner: false,
        theme: themeToUse,
        home: const MainScreen(),
      ),
    );
  }

  void changeTheme({bool stateChange = true}) {
    if ((prefs.getBool(settingUseDarkTheme) ?? true)) {
      themeToUse = jsonBuddyThemeDark;
    } else {
      themeToUse = jsonBuddyThemeLight;
    }
    if (stateChange) {
      setState(() {});
    }
  }
}
