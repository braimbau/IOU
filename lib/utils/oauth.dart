import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Utils.dart';
import '../classes/user.dart';
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

  if (!await userExist(id))
    id = null;

  if (id == null) {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    id = googleUser.id;
    name = googleUser.displayName;
    photoUrl = googleUser.photoUrl;

    print("Id = $id $name $photoUrl");


    prefs.setString("userId", id);
  }
  
  print("=============USER ID B= $id");

  if (!await userExist(id)) {
    print("creating new user... with $name $photoUrl and $id");
    await createUser(name, photoUrl, id);
  }
  return await getUserById(id);
}
