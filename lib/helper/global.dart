import 'package:flutter/widgets.dart';
import 'package:json_buddy/helper/json_formater.dart';
import 'package:json_buddy/helper/short_cut_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;
const String settingUseDarkTheme = "settingUseDarkTheme";
const String settingCodeTheme = "settingCodeTheme";
const String settingIndent = "settingIndent";
const String indentChar = " ";
JsonFormater customJsonFormater = JsonFormater();
const String defaultFontFamily = "monospace";

class GlobalConfig {
  static final shortCutProvider = ShortCutProvirer();
  static String currentLanguage = "en";
}

bool isDesktopSize(BuildContext context) =>
    MediaQuery.of(context).size.width > 1000;
