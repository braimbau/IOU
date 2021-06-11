import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/history.dart';
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







