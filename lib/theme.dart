import 'package:flutter/material.dart';

final ThemeData jsonBoddyTheme = ThemeData(
  brightness: Brightness.dark,
  inputDecorationTheme: const InputDecorationTheme(
    focusColor: Colors.white,
    labelStyle: TextStyle(color: Colors.white),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        style: BorderStyle.solid,
        color: Colors.white,
      ),
    ),
    suffixIconColor: Colors.white,
    prefixIconColor: Colors.white,
  ),
);
