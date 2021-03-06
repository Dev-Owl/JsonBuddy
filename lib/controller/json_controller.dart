import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/json.dart';
import 'package:json_buddy/helper/global.dart';

class JsonController extends TextEditingController {
  FormatException? _errorPresent;
  int errorLine = 0;
  TextSpan? _spanCache;
  String _prevText = "";
  bool get errorPresent => _errorPresent != null;
  FormatException? get lastError => _errorPresent;

  JsonController() {
    highlight.registerLanguage('json', json);
  }
  void clearCache() {
    _prevText = "";
    _spanCache = null;
  }

  void formatError(FormatException? ex) {
    _errorPresent = ex;
    if (_errorPresent != null &&
        _errorPresent!.offset != null &&
        _errorPresent!.source != null) {
      int lineNum = 0;
      final offset = _errorPresent!.offset!;
      final source = _errorPresent!.source!.toString();

      int lineStart = 0;
      bool previousCharWasCR = false;
      for (int i = 0; i < offset; i++) {
        int char = source.codeUnitAt(i);
        if (char == 0x0a) {
          if (lineStart != i || !previousCharWasCR) {
            lineNum++;
          }
          lineStart = i + 1;
          previousCharWasCR = false;
        } else if (char == 0x0d) {
          lineNum++;
          lineStart = i + 1;
          previousCharWasCR = true;
        }
      }
      errorLine = lineNum;
      selection = TextSelection.collapsed(offset: offset);
    }
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    if (_prevText == text && _spanCache != null) {
      return _spanCache!;
    }
    List<TextSpan> children = [];
    final themeToUse = prefs.getString(settingCodeTheme) ?? 'vs';
    final theme = themeMap[themeToUse];
    if (errorPresent) {
      children.addAll(_tryFormatWithError());
    } else {
      final syntaxNodes = highlight.parse(
        text,
        language: 'json',
      );

      if ((syntaxNodes.relevance ?? 0) > 0) {
        children = _convert(syntaxNodes.nodes!, theme);
      } else {
        children.addAll(_tryFormatWithError());
      }
    }

    _spanCache = TextSpan(
        children: children,
        style: theme!["root"]!.copyWith(fontFamily: defaultFontFamily));
    _prevText = text;
    return _spanCache!;
  }

  List<TextSpan> _tryFormatWithError() {
    List<TextSpan> children = [];
    final themeToUse = prefs.getString(settingCodeTheme) ?? 'vs';
    final list = text.split('\n');
    for (var i = 0; i < list.length; ++i) {
      final childStyle = errorPresent && i == errorLine
          ? themeMap[themeToUse]!['root']!.copyWith(
              color: Colors.red,
              backgroundColor: const Color(0xFFfbe3e4),
            )
          : themeMap[themeToUse]!['root'];

      children.add(TextSpan(
        text: "${list[i]}\n",
        style: childStyle,
      ));
    }
    return children;
  }

  List<TextSpan> _convert(List<Node> nodes, Map<String, TextStyle>? theme) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    _traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(
          node.className == null
              ? TextSpan(text: node.value)
              : TextSpan(
                  text: node.value,
                  style: theme![node.className!],
                ),
        );
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans.add(
          TextSpan(
            children: tmp,
            style: theme![node.className!],
          ),
        );
        stack.add(currentSpans);
        currentSpans = tmp;

        for (var n in node.children!) {
          _traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        }
      }
    }

    for (var node in nodes) {
      _traverse(node);
    }

    return spans;
  }
}
