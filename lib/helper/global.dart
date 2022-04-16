import 'package:json_buddy/helper/json_formater.dart';
import 'package:json_buddy/helper/short_cut_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;
const String settingUseDarkTheme = "settingUseDarkTheme";
const String settingCodeTheme = "settingCodeTheme";
const String settingIndent = "settingIndent";
const String indentChar = " ";
JsonFormater customJsonFormater = JsonFormater();

class GlobalConfig {
  static final shortCutProvider = ShortCutProvirer();
  static String currentLanguage = "en";
}
