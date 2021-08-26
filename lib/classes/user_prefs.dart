import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const String themeKey = "theme";
  static int theme = 0;

  static const String languageKey = "language";
  static String language = "en";

  void update(SharedPreferences prefs) {
    theme = prefs.getInt(themeKey);
    language = prefs.getString(languageKey);
  }

  void toggleLanguage() {
    if (language == 'fr')
      language = 'en';
    else
      language = 'fr';
  }
}