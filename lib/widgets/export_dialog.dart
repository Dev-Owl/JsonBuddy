import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_buddy/helper/theme.dart';

enum ExportFormat { cvs, xml }

class ExportDialog extends StatefulWidget {
  final dynamic currentModel;

  const ExportDialog(this.currentModel, {Key? key}) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late ExportFormat selectedExport;
  final seperatorTextController = TextEditingController(text: ";");
  final keySeperatorTextController = TextEditingController(text: "-");
  final formKey = GlobalKey<FormState>();
  var pathSegmentSign = "-";
  var csvSeperator = ";";
  @override
  void initState() {
    selectedExport = ExportFormat.cvs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          ListTile(
            title: const Text('Export format'),
            subtitle: DropdownButton<ExportFormat>(
              value: selectedExport,
              items: ExportFormat.values
                  .map(
                    (e) => DropdownMenuItem(
                      child: Text(e.name.toUpperCase()),
                      value: e,
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedExport = newValue;
                  });
                }
              },
              isExpanded: true,
            ),
          ),
          ListTile(
            title: const Text('CSV Seperator'),
            subtitle: TextFormField(
              enabled: selectedExport == ExportFormat.cvs,
              controller: seperatorTextController,
              decoration: const InputDecoration(
                helperText: 'Usually ; or ,',
              ),
              validator: (value) {
                if (value == null || value.isEmpty || value.length > 1) {
                  return "A single char is required";
                }
                return null;
              },
            ),
          ),
          ListTile(
            title: const Text('Key Seperator'),
            subtitle: TextFormField(
              enabled: selectedExport == ExportFormat.cvs,
              controller: keySeperatorTextController,
              decoration: const InputDecoration(
                helperText: "This char can't be part of any JSON key",
              ),
              validator: (value) {
                if (value == null || value.isEmpty || value.length > 1) {
                  return "A single char is required";
                }
                return null;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  child: const Text('Cancle'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              Expanded(
                child: ElevatedButton(
                  child: const Text('Export'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _runExport();
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future _runExport() async {
    if (selectedExport == ExportFormat.cvs) {
      pathSegmentSign = keySeperatorTextController.text;
      pathSegmentSign = keySeperatorTextController.text;
      try {
        finalCSVKeys.clear();
        List<String> paths = [];
        if (widget.currentModel is Map<String, dynamic>) {
          paths.addAll(getKeysFromObj(widget.currentModel));
        } else if (widget.currentModel is List<dynamic>) {
          for (final obj in widget.currentModel) {
            paths.addAll(getKeysFromObj(obj));
          }
        }

        //Duplicates should not exists, safe is safe
        paths = paths.toSet().toList();
        //Remove parent objects from list
        _cleanPaths(paths);
        //We write the CSV keys at the end
        var buffer = StringBuffer();
        if (widget.currentModel is List<dynamic>) {
          for (final obj in widget.currentModel) {
            if (buffer.isNotEmpty) {
              buffer.writeln();
            }
            _rowForObject(buffer, paths, obj);
            final line = buffer.toString();
            buffer = StringBuffer(line.substring(0, line.length - 1));
          }
        } else {
          _rowForObject(buffer, paths, widget.currentModel);
          final line = buffer.toString();
          buffer = StringBuffer(line.substring(0, line.length - 1));
        }
        await _saveToFile(finalCSVKeys.toSet().toList().join(csvSeperator) +
            "\n" +
            buffer.toString());
        Navigator.of(context).pop();
      } catch (e) {
        const snackBar = SnackBar(
          content: Text(
            'Unable to export, ensure that the Key Seperator is not used in any JSON key',
          ),
          backgroundColor: errorColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future _saveToFile(String output) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'my_csv.csv',
      lockParentWindow: true,
    );
    if (outputFile != null) {
      try {
        final fileOnDisk = File(outputFile);
        fileOnDisk.writeAsString(output);
      } catch (ex) {
        //TODO refactor, duplicate add generic error snackbar
        const snackBar = SnackBar(
          content: Text(
            'Error saving your file',
          ),
          backgroundColor: errorColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  List<String> getKeysFromObj(Map<String, dynamic> jsonModel) {
    //Get all JSON keys as path like key-key-key
    List<String> paths = jsonModel.keys.toList();
    for (var item in jsonModel.entries) {
      paths.addAll(_scanForKey(item.value, preFix: item.key));
    }
    return paths;
  }

  List<String> finalCSVKeys = [];

  List<String> _cleanPaths(List<String> paths) {
    final parentObjects = paths
        .where((element) => element.contains(pathSegmentSign))
        .map((e) => e.split(pathSegmentSign).first)
        .toList();
    paths.removeWhere((element) => parentObjects.contains(element));
    return paths;
  }

  void _rowForObject(
      StringBuffer buffer, List<String> csvKeys, Map<String, dynamic> obj,
      {String? parent}) {
    List<String> skipList = [];
    _cleanPaths(csvKeys);
    for (final currentPath in csvKeys) {
      if (skipList.contains(currentPath)) continue;

      if (currentPath.contains(pathSegmentSign)) {
        final parent = currentPath.split(pathSegmentSign).first;
        final childPaths = csvKeys
            .where((element) =>
                element.contains(pathSegmentSign) && element.startsWith(parent))
            .toList();
        skipList.addAll(childPaths);
        final nextObj = obj[parent];
        final cleanedPaths = childPaths
            .map(
              (e) => e.split(pathSegmentSign).sublist(1).join(pathSegmentSign),
            )
            .toList();
        if (nextObj is List<dynamic>) {
          finalCSVKeys.add('[${childPaths.join(',')}]');
          _createValueCSV(buffer, nextObj);
        } else {
          _rowForObject(buffer, cleanedPaths, nextObj, parent: parent);
        }
      } else {
        finalCSVKeys.add(parent == null ? currentPath : "$parent-$currentPath");
        _createValueCSV(buffer, obj[currentPath]);
      }
    }
  }

  void _createValueCSV(StringBuffer buffer, dynamic value) {
    if (value != null && value is num) {
      buffer.write(value);
    } else {
      buffer.write('"${value ?? ""}"');
    }
    buffer.write(csvSeperator);
  }

  List<String> _scanForKey(dynamic object, {required String preFix}) {
    List<String> newKeys = [];

    if (object is Map<String, dynamic>) {
      newKeys.addAll(object.keys.map((e) => _buildPath([preFix, e])));
      for (var item in object.entries) {
        newKeys.addAll(_scanForKey(
          item.value,
          preFix: _buildPath([preFix, item.key]),
        ));
      }
    } else if (object is List<dynamic>) {
      for (var item in object) {
        newKeys.addAll(_scanForKey(
          item,
          preFix: preFix,
        ));
      }
    }
    return newKeys;
  }

  String _buildPath(List<String> segments) {
    return segments.join(pathSegmentSign);
  }
}
