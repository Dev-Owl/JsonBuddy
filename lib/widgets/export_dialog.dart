import 'package:flutter/material.dart';

enum ExportFormat { cvs, xml }

class ExportDialog extends StatefulWidget {
  final dynamic currentModel;

  const ExportDialog(this.currentModel, {Key? key}) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late ExportFormat selectedExport;

  @override
  void initState() {
    selectedExport = ExportFormat.cvs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        const ListTile(
          title: Text('Search depth'),
          subtitle: Text('select the depth'),
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
                  //Navigator.of(context).pop();
                  _runExport();
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Future _runExport() async {
    if (selectedExport == ExportFormat.cvs) {
      Map<String, dynamic> jsonModel = widget.currentModel;
      //Get all JSON keys as path like key-key-key
      List<String> csvKeys = jsonModel.keys.toList();
      for (var item in jsonModel.entries) {
        csvKeys.addAll(_scanForKey(item.value, preFix: item.key));
      }
      //Duplicates should not exists, safe is safe
      csvKeys = csvKeys.toSet().toList();
      var buffer = StringBuffer();
      buffer.writeln(csvKeys.join(','));
      if (widget.currentModel is List<dynamic>) {
        for (final obj in widget.currentModel) {
          _rowForObject(buffer, csvKeys, obj);
        }
      } else {
        _rowForObject(buffer, csvKeys, widget.currentModel);
      }
    }
  }

  //TODO from here on, see how row can be genrated, idea is that each obj
  //  gets checked for the path if it exists in the object

  void _rowForObject(StringBuffer buffer, List<String> csvKeys, dynamic obj) {
    for (final key in csvKeys) {
      _createCsvRow(buffer, key, obj);
    }
  }

  void _createCsvRow(StringBuffer buffer, String path, dynamic obj) {
    if (path.contains(pathSegmentSign)) {
    } else {}
  }

  void _createValueCSV(StringBuffer buffer, dynamic value, bool last) {
    buffer.write(value);
    if (last == false) {
      buffer.write(csvSeperator);
    } else {
      buffer.writeln();
    }
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

  final pathSegmentSign = "-";
  final csvSeperator = ";";
  String _buildPath(List<String> segments) {
    return segments.join(pathSegmentSign);
  }
}
