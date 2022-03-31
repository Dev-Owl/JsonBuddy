import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_buddy/line_number_text_field.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.text = '{"name":"John", "age" 30, "car":null}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Buddy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: LineNumberTextField(
          textEditingController: controller,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.play_arrow,
          ),
          onPressed: () {
            const decoder = JsonDecoder();
            try {
              final model = decoder.convert(controller.text);
              const encoder = JsonEncoder.withIndent('  ');
              controller.text = encoder.convert(model);
            } on FormatException catch (ex) {
              final snackBar = SnackBar(
                content: Text(ex.toString()),
                backgroundColor: Colors.red[300],
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              //TODO(CM): Mark the related text part red
            }
          }),
    );
  }
}
