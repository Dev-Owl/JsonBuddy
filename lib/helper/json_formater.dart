import 'package:json_buddy/helper/global.dart';

class JsonFormater {
  String formatText(String input) {
    final indent = (prefs.getInt(settingIndent) ?? 2);
    final indentToUse = '' * indent;
    var formatedResult = '';
    var currentLevel = 0;
    var inQuotes = false;
    var inEscape = false;
    int? endsLineLevel;
    for (var i = 0; i < input.length; i++) {
      var char = input[i];
      int? newLineLevel;
      var post = "";
      if (endsLineLevel != null) {
        newLineLevel = endsLineLevel;
        endsLineLevel = null;
      }
      if (inEscape) {
        inEscape = false;
      } else if (char == '"') {
        inQuotes = !inQuotes;
      } else if (!inQuotes) {
        switch (char) {
          case '}':
          case ']':
            currentLevel--;
            endsLineLevel = null;
            newLineLevel = currentLevel;
            break;

          case '{':
          case '[':
            currentLevel++;
            post = "\n" + indentToUse * currentLevel;
            break;
          case ',':
            endsLineLevel = currentLevel;
            break;

          case ':':
            post = indentToUse;
            break;

          case " ":
          case "\t":
          case "\n":
          case "\r":
            char = "";
            endsLineLevel = newLineLevel;
            newLineLevel = null;
            break;
        }
      } else if (char == '\\') {
        inEscape = true;
      }
      if (newLineLevel != null) {
        formatedResult += "\n" + indentToUse * newLineLevel;
      }
      formatedResult += char + post;
    }

    return formatedResult.trim();
  }
}
