import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:json_buddy/global.dart';

class LineNumberController extends TextEditingController {
  LineNumberController();

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final children = <TextSpan>[];
    final list = text.split('\n');
    const themeClassToUse = 'root';
    for (var k = 0; k < list.length; k++) {
      final textSpan = TextSpan(
          text: '${k + 1}',
          style: themeMap[GlobalConfig.codeTheme]![themeClassToUse]);
      children.add(textSpan);
      if (k < list.length - 1) children.add(const TextSpan(text: '\n'));
    }
    return TextSpan(
      children: children,
    );
  }
}
