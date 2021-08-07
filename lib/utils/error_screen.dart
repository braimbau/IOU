import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Routes/log_screen.dart';

Widget errorScreen(String err) {
  return (Scaffold(
  body: Center(
    child: Text(err, style: TextStyle(color: Colors.red, fontSize: 15)),
  )));
}

Widget logErrorScreen(String err, BuildContext context) {
  return (Scaffold(
      body: Center(
          child: Row(
              children: [
                Text(err, style: TextStyle(color: Colors.red, fontSize: 15)),
                TextButton(
                    onPressed: () async {
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString("userId", null);
                      prefs.setString("name", null);
                      prefs.setString("photoUrl", null);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(pageBuilder: (context, animation1, animation2) => LogScreen(), transitionDuration: Duration(seconds: 0)),
                      );
                    },
                    child: Text("Retry")),
              ]
          ))));
}