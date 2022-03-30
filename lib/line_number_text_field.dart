import 'dart:math';

import 'package:flutter/material.dart';
import 'package:json_buddy/line_number_controller.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class LineNumberTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  const LineNumberTextField({required this.textEditingController, Key? key})
      : super(key: key);

  @override
  State<LineNumberTextField> createState() => _LineNumberTextFieldState();
}

class _LineNumberTextFieldState extends State<LineNumberTextField> {
  LineNumberController? _lineNumberController;

  ScrollController? _scrollController;

  ScrollController? _scrollController1;

  LinkedScrollControllerGroup? _controllers;

  @override
  void initState() {
    super.initState();
    _lineNumberController = LineNumberController()..text = "";

    widget.textEditingController.addListener(() {
      _lineNumberController!.text = widget.textEditingController.text;
    });

    _controllers = LinkedScrollControllerGroup();

    _scrollController = _controllers?.addAndGet();
    _scrollController1 = _controllers?.addAndGet();
  }

  // Wrap the codeField in a horizontal scrollView
  Widget _wrapInScrollView(Widget codeField, double minWidth) {
    const leftPad = 0.0;
    final longestLine = widget.textEditingController.text
        .split('\n')
        .fold<String>('', (p, e) => p.length < e.length ? e : p);
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0.0,
              minWidth: max(minWidth - leftPad, 0.0),
            ),
            child: Padding(
              child: Text(longestLine),
              padding: const EdgeInsets.only(right: 16.0),
            ), // Add extra padding
          ),
          Expanded(child: codeField),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: leftPad),
      scrollDirection: Axis.horizontal,
      child: intrinsic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lineNumberCol = TextField(
      controller: _lineNumberController,
      enabled: false,
      maxLines: null,
      scrollController: _scrollController,
      decoration: const InputDecoration(
        disabledBorder: InputBorder.none,
      ),
    );

    final field = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Control horizontal scrolling
        return _wrapInScrollView(
            TextField(
              controller: widget.textEditingController,
              scrollController: _scrollController1,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
            constraints.maxWidth);
      },
    );

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.only(left: 3),
            child: lineNumberCol,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(),
              ),
              color: Color(0xFFf0f0f0),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(child: field),
        ],
      ),
    );
  }
}
