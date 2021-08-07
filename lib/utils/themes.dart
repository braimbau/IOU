import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode=> themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  static final ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[900],
      backgroundColor: Colors.grey[100],
      textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
      headline2: TextStyle(
          fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        headline3: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          bodyText1: TextStyle(
            color: Colors.white,
          ),
        bodyText2: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[800],
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    primaryColor: Colors.white,
    cardTheme: CardTheme(
      color: Colors.grey[900]
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
    ),
  );

  static final ThemeData light = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100],
      backgroundColor: Colors.grey[900],
      textTheme: TextTheme(
        headline1: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        headline2: TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
        headline3: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        bodyText1: TextStyle(
          color: Colors.black,
        ),
        bodyText2: TextStyle(
        color: Colors.black,
          fontWeight: FontWeight.bold
      ),

      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[300],
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      primaryColor: Colors.black,
    cardTheme: CardTheme(
        color: Colors.grey[100],
    ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
      ),
  );
}
