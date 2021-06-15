import 'package:deed/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'error_screen.dart';
import 'oauth.dart';
import 'main_page.dart';
import 'user.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final Future<IOUser> user = signInWithGoogle();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: user,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return logErrorScreen("An error occured while login whith Google", context);
        }
        // Once complete, show your application

        if (snapshot.connectionState == ConnectionState.done) {
          return (mainPage(context, snapshot.data));
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Loading();
      },
    );
  }
}