import 'package:flutter/material.dart';

enum JsonBuddyShortcut {
  search,
  validateCode,
}

class ShortCutProvirer {
  final Map<JsonBuddyShortcut, List<VoidCallback>> _shortCuts = {};
  ShortCutProvirer() {
    for (var element in JsonBuddyShortcut.values) {
      _shortCuts[element] = [];
    }
  }

  void addSearchListner(
      JsonBuddyShortcut targetShortcut, VoidCallback callback) {
    _shortCuts[targetShortcut]!.add(callback);
  }

  void removeSearchListner(
      JsonBuddyShortcut targetShortcut, VoidCallback callback) {
    _shortCuts[targetShortcut]!.remove(callback);
  }

  void triggerShortcut(JsonBuddyShortcut targetShortcut) {
    for (var element in _shortCuts[targetShortcut]!) {
      element.call();
    }
  }
}
