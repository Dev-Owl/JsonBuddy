import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_buddy/helper/global.dart';
import 'package:json_buddy/helper/debouncer.dart';
import 'package:json_buddy/helper/globalization.dart';
import 'package:json_buddy/helper/json_formater.dart';
import 'package:json_buddy/helper/short_cut_provider.dart';
import 'package:json_buddy/controller/json_controller.dart';
import 'package:json_buddy/widgets/line_number_text_field.dart';
import 'package:json_buddy/widgets/settings_dialog.dart';
import 'package:json_buddy/helper/theme.dart';
import 'package:json_path/json_path.dart';
import 'package:pulse_widget/pulse_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Controller for the main text in the application
  late final JsonController jsonController;

  late final TextEditingController searchController;

  late final JsonController filteredTextController;

  /// Tracks if we want to show the search in the appbar
  bool searchModeActive = false;

  /// Last error that has ocoured for parsing provided JSON
  FormatException? lastError;

  /// The current model parsed from json, if any otherwise null
  dynamic currentParsedModel;

  /// Used to debounce search requests
  final debouncer = Debouncer();

  /// Filter syntax error indicator
  bool filterSyntaxError = false;

  /// Format JSON even with syntax errors
  final JsonFormater anyWayFormat = JsonFormater();

  /// Focus node for the search input
  final searchFocusNode = FocusNode();

  /// Callback that is tirggered by the search
  late final VoidCallback searchHotkeyCallback;

  /// Indicate if we should show a pulse to inform the user to parse the text
  bool showPulse = true;

  /// Indeicate if an user drags a file into the app
  bool draggingActive = false;

  @override
  void initState() {
    super.initState();
    jsonController = JsonController();
    jsonController.text =
        '{"name":"John", "age": 30, "car":[123.5,"fast"], "happy":true, "hobby":{"development":true}}';
    filteredTextController = JsonController();

    searchController = TextEditingController(text: "\$.*");
    searchController.addListener(() {
      debouncer(() {
        _applySearch();
      });
    });
    searchHotkeyCallback = () => _setSearchMode(!searchModeActive);
    GlobalConfig.shortCutProvider.addSearchListner(
      JsonBuddyShortcut.search,
      searchHotkeyCallback,
    );
    GlobalConfig.shortCutProvider.addSearchListner(
      JsonBuddyShortcut.validateCode,
      _tryparse,
    );
  }

  void _userChangedText() {
    debouncer(() => setState(() {
          showPulse = true;
        }));
  }

  @override
  void dispose() {
    GlobalConfig.shortCutProvider.removeSearchListner(
      JsonBuddyShortcut.search,
      searchHotkeyCallback,
    );
    GlobalConfig.shortCutProvider.removeSearchListner(
      JsonBuddyShortcut.validateCode,
      _tryparse,
    );
    super.dispose();
  }

  void _setSearchMode(bool newMode) {
    setState(() {
      searchModeActive = newMode;
      if (searchModeActive) {
        searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      child: Scaffold(
        appBar: _createAppBar(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.orange[300]!,
                ),
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Image(
                        fit: BoxFit.scaleDown,
                        image: AssetImage('assets/images/logo_128.png'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'JSON Buddy',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.save_as),
                title: const Text('Export'),
                onTap: () async {
                  Navigator.pop(context);
                  String? outputFile = await FilePicker.platform.saveFile(
                    dialogTitle: 'Please select an output file:',
                    fileName: 'my_json.json',
                    lockParentWindow: true,
                  );
                  if (outputFile != null) {
                    try {
                      final fileOnDisk = File(outputFile);
                      fileOnDisk.writeAsString(jsonController.text);
                    } catch (ex) {
                      const snackBar = SnackBar(
                        content: Text(
                          'Error saving your file',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.compress),
                title: const Text('Minify'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Setting'),
                onTap: () {
                  Navigator.pop(context);
                  _showMyDialog();
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: LineNumberTextField(
                filteredTextEditingController: filteredTextController,
                textEditingController: jsonController,
                userTextChangeCallback: _userChangedText,
                currentError: lastError,
                displayFilterView: searchModeActive,
              ),
            ),
            if (draggingActive)
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 350,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    Translation.getText('drop_file_message'),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: Translation.getText('parse_JSON'),
          child: Pulse(
            shouldShowPulse: showPulse,
            child: const Icon(Icons.code),
          ),
          onPressed: _tryparse,
        ),
      ),
      onDragDone: (eventDetails) {
        final file = eventDetails.files.first;
        file.readAsString().then((value) {
          try {
            jsonController.text = value;
            _tryparse();
          } catch (ex) {
            jsonController.text = "";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Translation.getText('read_file_error'),
                ),
              ),
            );
          }
        });
        setState(() {
          draggingActive = false;
        });
      },
      onDragEntered: (eventDetails) {
        setState(() {
          draggingActive = true;
        });
      },
      onDragExited: (eventDetails) {
        setState(() {
          draggingActive = false;
        });
      },
    );
  }

  AppBar _createAppBar() {
    Widget? child;
    List<Widget> actions = [];
    if (searchModeActive) {
      child = SizedBox(
        width: double.infinity,
        height: 40,
        child: Center(
          child: TextField(
            focusNode: searchFocusNode,
            controller: searchController,
            decoration: InputDecoration(
              hintText: Translation.getText('search_hint_text'),
              prefixIcon: const Icon(Icons.search),
              filled: filterSyntaxError,
              fillColor: filterSyntaxError ? errorColor : null,
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _setSearchMode(false);
                },
                tooltip: Translation.getText('close_search_tooltip'),
              ),
            ),
          ),
        ),
      );
    } else {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            onPressed: currentParsedModel == null
                ? null
                : () {
                    _setSearchMode(true);
                  },
            icon: const Icon(Icons.search),
            tooltip: currentParsedModel == null
                ? Translation.getText('search_tooltip_model_missing')
                : Translation.getText('search_tooltip'),
          ),
        ),
      );
    }
    return AppBar(
      title: child,
      actions: actions,
    );
  }

  void _applySearch() {
    if (currentParsedModel != null) {
      late final JsonPath jsonPath;
      try {
        jsonPath = JsonPath(searchController.text);
      } catch (ex) {
        filteredTextController.text = "";
        setState(() {
          filterSyntaxError = true;
        });
        return;
      }
      setState(() {
        filterSyntaxError = false;
      });
      final matchedResult = jsonPath.read(currentParsedModel);
      final values = matchedResult.map((match) => match.value).toList();
      final indent = prefs.getInt(settingIndent) ?? 2;
      final encoder = JsonEncoder.withIndent(' ' * indent);
      filteredTextController.text = encoder.convert(values);
    } else {
      filteredTextController.text = "";
    }
  }

  void _tryparse() {
    const decoder = JsonDecoder();
    showPulse = false;
    try {
      final indent = prefs.getInt(settingIndent) ?? 2;
      jsonController.text = anyWayFormat.formatText(jsonController.text);
      currentParsedModel = decoder.convert(jsonController.text);
      final encoder = JsonEncoder.withIndent(' ' * indent);
      jsonController.text = encoder.convert(currentParsedModel);
      if (searchModeActive) {
        _applySearch();
      }
      jsonController.formatError(null);
      setState(() {
        lastError = null;
      });
    } on FormatException catch (ex) {
      currentParsedModel = null;
      jsonController.formatError(ex);
      _applySearch();
      setState(() {
        lastError = ex;
      });
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Translation.getText('setting_title'),
          ),
          content: SizedBox(
            height: 250,
            width: 325,
            child: SettingsDialog(
              onCodeThemeChange: _tryparse,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
