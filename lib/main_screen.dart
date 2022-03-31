import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_buddy/line_number_text_field.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

//TODO(CM): The textfield has to create the controller
/*          The error must below the textfield
            The error part in the text should be marked red
            The serach needs to be implemented
*/

class _MainScreenState extends State<MainScreen> {
  late final TextEditingController controller;
  bool showSearchInAppBar = false;
  FormatException? lastError;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.text = '{"name":"John", "age" 30, "car":null}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: LineNumberTextField(
              textEditingController: controller,
              currentError: lastError,
            ),
          ),
          if (lastError != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                color: Colors.red,
                width: double.infinity,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: Text(
                  lastError.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
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
            setState(() {
              lastError = null;
            });
          } on FormatException catch (ex) {
            setState(() {
              lastError = ex;
            });
          }
        },
      ),
    );
  }

  AppBar _createAppBar() {
    late Widget child;
    List<Widget> actions = [];
    if (showSearchInAppBar) {
      child = Container(
        width: double.infinity,
        height: 40,
        color: Colors.white,
        child: Center(
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Search for something using JsonPath',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      showSearchInAppBar = false;
                    });
                  },
                )),
          ),
        ),
      );
    } else {
      child = const Text('JSON Buddy');
      actions.add(
        IconButton(
          onPressed: () {
            setState(() {
              showSearchInAppBar = true;
            });
          },
          icon: const Icon(Icons.search),
        ),
      );
    }
    return AppBar(
      title: child,
      actions: actions,
    );
  }
}
