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
import 'package:json_buddy/helper/version.dart';
import 'package:json_buddy/widgets/export_dialog.dart';
import 'package:json_buddy/widgets/line_number_text_field.dart';
import 'package:json_buddy/widgets/main_menu.dart';
import 'package:json_buddy/widgets/main_menu_item.dart';
import 'package:json_buddy/widgets/settings_dialog.dart';
import 'package:json_buddy/helper/theme.dart';
import 'package:json_path/json_path.dart';
import 'package:pulse_widget/pulse_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
        '{"name":"John", "age": 30, "car":[123.5,"fast"], "happy":true, "hobby":{"development":true,"hard":[{"hard":true}]}}';
    filteredTextController = JsonController();

    searchController = TextEditingController(text: "\$.*");
    searchController.addListener(() {
      debouncer(() {
        _applySearch();
      });
    });
    searchHotkeyCallback = () => _setSearchMode(!searchModeActive);
    GlobalConfig.shortCutProvider.addShortCutListner(
      JsonBuddyShortcut.search,
      searchHotkeyCallback,
    );
    GlobalConfig.shortCutProvider.addShortCutListner(
      JsonBuddyShortcut.validateCode,
      _tryparse,
    );
    GlobalConfig.shortCutProvider.addShortCutListner(
      JsonBuddyShortcut.minify,
      _tryMinify,
    );
    GlobalConfig.shortCutProvider.addShortCutListner(
      JsonBuddyShortcut.saveFile,
      _saveToFile,
    );
    GlobalConfig.shortCutProvider.addShortCutListner(
      JsonBuddyShortcut.openFile,
      _openFile,
    );
    GlobalConfig.shortCutProvider.addShortCutListner(
      JsonBuddyShortcut.exportFile,
      _showExportDialog,
    );
  }

  void _tryMinify() {
    if (currentParsedModel != null) {
      jsonController.text = customJsonFormater.minify(currentParsedModel);
    }
  }

  void _userChangedText() {
    debouncer(() => setState(() {
          showPulse = true;
        }));
  }

  @override
  void dispose() {
    GlobalConfig.shortCutProvider.removeShortCutListner(
      JsonBuddyShortcut.search,
      searchHotkeyCallback,
    );
    GlobalConfig.shortCutProvider.removeShortCutListner(
      JsonBuddyShortcut.validateCode,
      _tryparse,
    );
    GlobalConfig.shortCutProvider.removeShortCutListner(
      JsonBuddyShortcut.minify,
      _tryMinify,
    );
    GlobalConfig.shortCutProvider.removeShortCutListner(
      JsonBuddyShortcut.saveFile,
      _saveToFile,
    );
    GlobalConfig.shortCutProvider.removeShortCutListner(
      JsonBuddyShortcut.openFile,
      _openFile,
    );
    GlobalConfig.shortCutProvider.removeShortCutListner(
      JsonBuddyShortcut.exportFile,
      _showExportDialog,
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

  Widget _getMainMenu() {
    final noModelTooltip = Translation.getText('validateJsonFirst');
    return MainMenu(
      menuItems: [
        MainMenuItem(
          title: 'Open file',
          icon: Icons.file_open,
          toolTipText: 'CTRL + O',
          onTap: () {
            _openFile();
          },
        ),
        MainMenuItem(
          title: 'Save',
          icon: Icons.save_as,
          toolTipText: 'CTRL + S',
          onTap: () {
            _saveToFile();
          },
        ),
        MainMenuItem(
          title: 'Export',
          icon: Icons.import_export,
          toolTipText: currentParsedModel == null ? noModelTooltip : 'CTRL + E',
          onTap: currentParsedModel != null
              ? () {
                  _showExportDialog();
                }
              : null,
        ),
        MainMenuItem(
          title: 'Minify',
          icon: Icons.compress,
          toolTipText: currentParsedModel == null ? noModelTooltip : 'CTRL + i',
          onTap: currentParsedModel != null
              ? () {
                  _tryMinify();
                }
              : null,
        ),
        MainMenuItem(
          title: 'Setting',
          icon: Icons.settings,
          onTap: () {
            _showSettingDialog();
          },
        ),
        MainMenuItem(
          title: 'About',
          icon: Icons.info_outline_rounded,
          onTap: () {
            _showAboutDialog();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopSize(context);
    return DropTarget(
      child: Scaffold(
        appBar: _createAppBar(),
        drawer: isDesktop ? null : Drawer(child: _getMainMenu()),
        body: _buildContent(isDesktop),
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

  Widget _buildContent(bool isDesktop) {
    final innerChild = Padding(
      padding: const EdgeInsets.all(5),
      child: LineNumberTextField(
        filteredTextEditingController: filteredTextController,
        textEditingController: jsonController,
        userTextChangeCallback: _userChangedText,
        currentError: lastError,
        displayFilterView: searchModeActive,
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Expanded(
              child: _getMainMenu(),
              flex: 1,
            ),
          Expanded(child: innerChild, flex: 4),
        ],
      );
    } else {
      return innerChild;
    }
  }

  Future _openFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Open a JSON file',
        allowMultiple: false,
      );
      if (result != null) {
        final selectedFile = result.files.first;
        jsonController.text = await File(selectedFile.path!).readAsString();
      }
    } catch (ex) {
      const snackBar = SnackBar(
        content: Text(
          'Error opening your file',
        ),
        backgroundColor: errorColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future _saveToFile() async {
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
                ? Translation.getText('validateJsonFirst')
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
      jsonController.clearCache();
      final indent = prefs.getInt(settingIndent) ?? 2;
      currentParsedModel = decoder.convert(jsonController.text);
      final encoder = JsonEncoder.withIndent(' ' * indent);
      jsonController.text = encoder.convert(currentParsedModel);
      jsonController.formatError(null);
      setState(() {
        lastError = null;
      });
      if (searchModeActive) {
        _applySearch();
      }
    } on FormatException catch (ex) {
      currentParsedModel = null;
      jsonController.text = anyWayFormat.formatText(jsonController.text);
      jsonController.formatError(ex);
      _applySearch();
      setState(() {
        lastError = ex;
      });
    }
  }

  Future<void> _showExportDialog() async {
    if (currentParsedModel == null) return;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Translation.getText('export_title'),
          ),
          content: SizedBox(
            height: 225,
            width: 325,
            child: ExportDialog(
              currentParsedModel,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAboutDialog() async {
    showAboutDialog(
      context: context,
      applicationName: 'JSON Buddy',
      applicationIcon: const Image(
        fit: BoxFit.scaleDown,
        width: 64,
        height: 64,
        image: AssetImage('assets/images/logo_128.png'),
      ),
      children: [
        Column(
          children: [
            const ListTile(
              leading: Icon(Icons.api_sharp),
              title: Text('Version'),
              subtitle: Text(VersionInfo.versionName),
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Website & Support'),
              subtitle: const Text(VersionInfo.projectURL),
              onTap: () {
                launchUrl(Uri.parse(VersionInfo.projectURL));
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Contact'),
              subtitle: const Text(VersionInfo.contactMail),
              onTap: () {
                launchUrl(Uri.parse("mailto:${VersionInfo.contactMail}"));
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showSettingDialog() async {
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
