import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const TextTheme lightTextTheme = TextTheme(
    caption: TextStyle(fontSize: 16, color: Colors.black),
    bodyText1: TextStyle(fontSize: 18, fontFamily: 'Hind'),
    bodyText2: TextStyle(fontSize: 12, fontFamily: 'Hind'),
    headline6: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  static final ThemeData lightAppTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[900],
    appBarTheme:
        AppBarTheme(color: Colors.blue[900], elevation: 5, centerTitle: true),
    fontFamily: 'Georgia',
    textTheme: lightTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[900]!),
      ),
    ),
  );
}
