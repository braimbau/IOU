import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user.dart';
import 'package:shared_preferences/shared_preferences.dart';


FirebaseAuth auth = FirebaseAuth.instance;
Future<IOUser> signInWithGoogle() async {
  //check if user is already logged in
  String id;
  String name;
  String photoUrl;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  id = prefs.getString("userId");
  name = prefs.getString("name");
  photoUrl = prefs.getString("photoUrl");
  print("=============USER ID = $id");

  if (id == null) {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    name = googleUser.displayName;
    photoUrl = googleUser.photoUrl;
    id = googleUser.id;

    prefs.setString("userId", id);
    prefs.setString("name", name);
    prefs.setString("photoUrl", photoUrl);
  }

  if (!await isUser(id)) {
    print("creating new user...");
    createUser(name, photoUrl, id);
  }
  return IOUser(id, name, photoUrl);

}

Future<void> createUser(String name, String url, String id) async
{
  var  docRef = FirebaseFirestore.instance.collection('users').doc(id);
  docRef.set({'name': name, 'balance': 0, 'url' : url, 'id': id});
}

Future<bool> isUser(String id) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("users").doc(id);
  var doc = await document.get();
  return doc.exists;
}


