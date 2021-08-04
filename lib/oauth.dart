import 'package:cloud_firestore/cloud_firestore.dart';
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

  print("=============USER ID A = $id");

  if (id == null) {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    id = googleUser.id;
    name = googleUser.displayName;
    photoUrl = googleUser.photoUrl;

    prefs.setString("userId", id);
  }
  
  print("=============USER ID B= $id");

  if (!await isUser(id)) {
    print("creating new user... with $name $photoUrl and $id");
    await createUser(name, photoUrl, id);
  }
  return await getUserById(id);
}

Future<void> createUser(String name, String url, String id) async
{
  var  docRef = FirebaseFirestore.instance.collection('users').doc(id);
  docRef.set({'name': name, 'url' : url, 'id': id, 'groups': ""});
}

Future<bool> isUser(String id) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("users").doc(id);
  var doc = await document.get();
  return doc.exists;
}

Future<IOUser> getUserById (String id) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("users").doc(id);
  var doc = await document.get();
  IOUser usr = IOUser(id, doc["name"], doc["url"]);
  usr.setGroups(doc["groups"]);
  return usr;
}
