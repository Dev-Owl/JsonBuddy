import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view.dart';
import 'input.dart';
import 'highlighter.dart';

class Editor extends StatefulWidget {
  Editor({Key? key, this.path = ''}) : super(key: key);
  String path = '';
  @override
  _Editor createState() => _Editor();
}

class _Editor extends State<Editor> {
  bool fileSelected = false;
  String pathToFile = "";

  late DocumentProvider doc;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (fileSelected) {
      return MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => doc),
        Provider(create: (context) => Highlighter())
      ], child: InputListener(child: View()));
    } else {
      return TextButton(
        child: const Text('Select file'),
        onPressed: () async {
          try {
            final result = await FilePicker.platform.pickFiles(
              dialogTitle: 'Open a JSON file',
              allowMultiple: false,
            );
            if (result != null) {
              final selectedFile = result.files.first;
              doc = DocumentProvider();
              pathToFile = selectedFile.path!;
              doc.openFile(pathToFile);
              setState(() {
                fileSelected = true;
              });
            }
          } catch (ex) {
            const snackBar = SnackBar(
              content: Text(
                'Error opening your file',
              ),
              backgroundColor: Colors.red,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      );
    }
  }
}
