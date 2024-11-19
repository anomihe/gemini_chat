import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple, brightness: Brightness.light),
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xffE5E5E5),
    dividerColor: Colors.white54,
    useMaterial3: true);

ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, brightness: Brightness.light),
  primaryColor: Colors.blue,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xffE5E5E5),
  dividerColor: Colors.white54,
);
