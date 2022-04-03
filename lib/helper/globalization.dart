import 'package:json_buddy/helper/global.dart';

final en = {
  'drop_file_message': 'Drop your file to parse it',
  'parse_JSON': 'Parse JSON',
  'read_file_error': 'Unable to read the file',
  'search_hint_text': 'Search with use of JsonPath',
  'close_search_tooltip': 'Close search',
  'search_tooltip_model_missing': 'Validate JSON first',
  'search_tooltip': 'Search',
  'setting_tooltip': 'Settings',
  'setting_title': 'Settings',
};

final de = {
  'drop_file_message': 'Datei ablegen, um sie zu parsen',
  'parse_JSON': 'Parse JSON',
  'read_file_error': 'Die Datei kann nicht gelesen werden',
  'search_hint_text': 'Suche unter Verwendung von JsonPath',
  'close_search_tooltip': 'Suche schließen',
  'search_tooltip_model_missing': 'JSON zuerst validieren',
  'search_tooltip': 'Suchen',
  'setting_tooltip': 'Einstellungen',
  'setting_title': 'Einstellungen',
};

final valuesByLanguage = {
  'en': en,
  'de': de,
};

class Translation {
  static String getText(String translationKey) {
    return valuesByLanguage[GlobalConfig.currentLanguage]![translationKey] ??
        translationKey;
  }
}
