import 'package:flutter/material.dart';

enum JsonBuddyShortcut {
  search,
  validateCode,
  minify,
  saveFile,
  openFile,
  exportFile
}

class ShortCutProvirer {
  final Map<JsonBuddyShortcut, List<VoidCallback>> _shortCuts = {};
  ShortCutProvirer() {
    for (var element in JsonBuddyShortcut.values) {
      _shortCuts[element] = [];
    }
  }

  void addShortCutListner(
      JsonBuddyShortcut targetShortcut, VoidCallback callback) {
    _shortCuts[targetShortcut]!.add(callback);
  }

  void removeShortCutListner(
      JsonBuddyShortcut targetShortcut, VoidCallback callback) {
    _shortCuts[targetShortcut]!.remove(callback);
  }

  void triggerShortcut(JsonBuddyShortcut targetShortcut) {
    for (var element in _shortCuts[targetShortcut]!) {
      element.call();
    }
  }
}
