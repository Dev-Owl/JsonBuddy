import 'package:flutter/material.dart';

const errorColor = Color.fromARGB(255, 216, 54, 76);

final ThemeData jsonBuddyThemeDark = ThemeData(
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
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.white,
  ),
);

final ThemeData jsonBuddyThemeLight = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.orange[300]!,
    onPrimary: Colors.black,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.orange[300],
  ),
  inputDecorationTheme: const InputDecorationTheme(
    focusColor: Colors.black,
    labelStyle: TextStyle(color: Colors.black),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        style: BorderStyle.solid,
        color: Colors.black,
      ),
    ),
    suffixIconColor: Colors.black,
    prefixIconColor: Colors.black,
  ),
);
