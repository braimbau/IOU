import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  int getTheme() {
    if (themeMode == ThemeMode.system) return 0;
    if (themeMode == ThemeMode.dark) return 1;
    return 2;
  }

  void toggleTheme(int state) {
    if (state == 0) themeMode = ThemeMode.system;
    if (state == 1) themeMode = ThemeMode.dark;
    if (state == 2) themeMode = ThemeMode.light;
    notifyListeners();
  }
}

class ChangeThemeButtonWidget extends StatefulWidget {
  @override
  _ChangeThemeButtonWidgetState createState() =>
      _ChangeThemeButtonWidgetState();
}

class _ChangeThemeButtonWidgetState extends State<ChangeThemeButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final themProvider = Provider.of<ThemeProvider>(context);
    int theme = themProvider.getTheme();
    print("_$theme");
    return InkWell(
      onTap: () {
        theme++;
        if (theme == 3) theme = 0;
        final provider = Provider.of<ThemeProvider>(context, listen: false);
        provider.toggleTheme(theme);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
                visible: theme == 0,
                child: Text(
                  "A",
                  style: Theme.of(context).textTheme.headline3,
                )),
            Icon(Icons.lightbulb_outline),
          ],
        ),
      ),
    );
    return IconButton(
        icon: Icon(Icons.lightbulb),
        onPressed: () {
          theme++;
          if (theme == 3) theme = 0;
          final provider = Provider.of<ThemeProvider>(context, listen: false);
          provider.toggleTheme(theme);
          print(theme);
        });
  }
}

class MyThemes {
  static final ThemeData dark = ThemeData(
    fontFamily: GoogleFonts.roboto().fontFamily,
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
      bodyText2: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    primaryColor: Colors.white,
    cardTheme: CardTheme(color: Colors.grey[900]),
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
      bodyText2: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
