import 'package:flutter/material.dart';

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
    for (var k = 0; k < list.length; k++) {
      final textSpan = TextSpan(text: '${k + 1}', style: style);
      children.add(textSpan);
      if (k < list.length - 1) children.add(const TextSpan(text: '\n'));
    }
    return TextSpan(children: children, style: style);
  }
}
