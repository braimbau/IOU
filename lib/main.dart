import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/error_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';
import 'history.dart';
import 'user.dart';
import 'log_screen.dart';
import 'loading.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      LogScreen(group: deepLink.queryParameters['group'],),
                  transitionDuration: Duration(seconds: 0)),
            );
          }
          else
            print("null 1");

        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      print("link 2");
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                LogScreen(group: deepLink.queryParameters['group'],),
            transitionDuration: Duration(seconds: 0)),
      );
    }
    else
      print("null 2");
  }

  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Text("C'est la merde");
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            //return mainPage(context);
            return LogScreen();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Text("Ca charge bro attend");
        },
      );
  }


}







