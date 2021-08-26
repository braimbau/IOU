import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const String themeKey = "theme";
  static int theme = 0;

  static const String languageKey = "language";
  static String language = "en";

  void get(SharedPreferences prefs) {
    theme = prefs.getInt(themeKey);
    language = prefs.getString(languageKey);
  }
}