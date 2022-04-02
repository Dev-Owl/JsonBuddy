import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_buddy/global.dart';
import 'package:json_buddy/helper/debouncer.dart';
import 'package:json_buddy/helper/json_formater.dart';
import 'package:json_buddy/helper/short_cut_provider.dart';
import 'package:json_buddy/json_controller.dart';
import 'package:json_buddy/line_number_text_field.dart';
import 'package:json_buddy/settings_dialog.dart';
import 'package:json_buddy/theme.dart';
import 'package:json_path/json_path.dart';

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

  late final VoidCallback searchHotkeyCallback;

  @override
  void initState() {
    super.initState();
    jsonController = JsonController();
    jsonController.text =
        '{"name":"John", "age": 30, "car":null, "happy":true}';
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
  }

  @override
  void dispose() {
    GlobalConfig.shortCutProvider.removeSearchListner(
      JsonBuddyShortcut.search,
      searchHotkeyCallback,
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
    return Scaffold(
      appBar: _createAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: LineNumberTextField(
          filteredTextEditingController: filteredTextController,
          textEditingController: jsonController,
          currentError: lastError,
          displayFilterView: searchModeActive,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.code),
        onPressed: _tryparse,
      ),
    );
  }

  AppBar _createAppBar() {
    late Widget child;
    List<Widget> actions = [];
    Widget? leading;
    if (searchModeActive) {
      child = SizedBox(
        width: double.infinity,
        height: 40,
        child: Center(
          child: TextField(
            focusNode: searchFocusNode,
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search for something using JsonPath',
              prefixIcon: const Icon(Icons.search),
              filled: filterSyntaxError,
              fillColor: filterSyntaxError ? errorColor : null,
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _setSearchMode(false);
                },
                tooltip: 'Close search',
              ),
            ),
          ),
        ),
      );
    } else {
      child = const Text('JSON Buddy');
      leading = Padding(
        padding: const EdgeInsets.only(left: 15),
        child: IconButton(
          onPressed: currentParsedModel == null
              ? null
              : () {
                  _setSearchMode(true);
                },
          icon: const Icon(Icons.search),
          tooltip:
              currentParsedModel == null ? 'Validate JSON first' : 'Search',
        ),
      );
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            onPressed: () async {
              _showMyDialog();
            },
            icon: const Icon(
              Icons.settings,
            ),
            tooltip: 'Settings',
          ),
        ),
      );
    }
    return AppBar(
      leading: leading,
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
          title: const Text('Settings'),
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
