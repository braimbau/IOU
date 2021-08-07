import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../Utils.dart';
import '../classes/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<IOUser> signInWithGoogle() async {
  //check if user is already logged in
  String id;
  String name;
  String photoUrl;
  
  final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    id = "G:" + googleUser.id;
    name = googleUser.displayName;
    photoUrl = googleUser.photoUrl;

    print("Google Sign In = $id $name $photoUrl");

    prefs.setString("userId", id);
  

  if (!await userExist(id)) {
    print("creating new user... with $name $photoUrl and $id");
    await createUser(name, photoUrl, id);
  }
  return await getUserById(id);
}

Future<IOUser> signInWithApple() async {
  //check if user is already logged in
  String id;
  String name;
  String photoUrl;

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Trigger the authentication flow
  final appleUser = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.fullName,
    ],
  );


  id = "A:" + appleUser.userIdentifier;
  name = (appleUser.familyName == null) ? "Unknow user" : "${appleUser.givenName} ${appleUser.familyName}";
  photoUrl = "https://www.ndugaonwheels.com/wp-content/uploads/2020/04/apple.jpg";


  print("Apple Sign In = $id $name");

  prefs.setString("userId", id);


  if (!await userExist(id)) {
    print("creating new user... with $name $photoUrl and $id");
    await createUser(name, photoUrl, id);
  }
  return await getUserById(id);
}