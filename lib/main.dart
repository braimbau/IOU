import 'package:deed/Routes/join_group.dart';
import 'package:deed/utils/error.dart';
import 'package:deed/Other/invitation.dart';
import 'package:deed/Routes/main_page.dart';
import 'package:deed/utils/error_screen.dart';
import 'package:deed/utils/loading.dart';
import 'package:deed/utils/themes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Routes/log_screen.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.system,
    theme: MyThemes.light,
    darkTheme: MyThemes.dark,
    title: 'IOU',
    initialRoute: '/',
    routes: {
      '/': (context) => Home(
            args: ModalRoute.of(context).settings.arguments,
          ),
      '/joinGroup': (context) => JoinGroup(
            args: ModalRoute.of(context).settings.arguments,
          ),
      '/mainPage': (context) => MainPage(
            args: ModalRoute.of(context).settings.arguments,
          ),
    },
  ));
}

class Home extends StatefulWidget {
  final String args;

  Home({this.args});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  String groupInvite;

  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      await handleDynamicLink(dynamicLink, context);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      print("link 2");
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => LogScreen(
                  args: deepLink.queryParameters['group'],
                ),
            transitionDuration: Duration(seconds: 0)),
      );
    } else
      print("link null 2");
  }

  @override
  Widget build(BuildContext context) {
    groupInvite = this.widget.args;
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return errorScreen("An error occured while loading dynamic links");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          //return mainPage(context);
          return LogScreen(
            args: groupInvite,
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Loading();
      },
    );
  }

  Future<void> handleDynamicLink(
    PendingDynamicLinkData dynamicLink,
    BuildContext context,
  ) async {
    final Uri deepLink = dynamicLink?.link;

    if (deepLink != null) {
      String group = deepLink.queryParameters['group'];
      if (!await groupExist(group)) {
        displayError("This group doesn't exist anymore", context);
        return;
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String usrId = prefs.getString("userId");
      if (usrId == null) {
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
        Navigator.of(context).pushReplacementNamed('/', arguments: group);
        return;
      }
      print(
          "is in group ${await userIsInGroup(group, usrId)}, group $group usrid $usrId");
      if (await userIsInGroup(group, usrId) == false)
        showInvitation(context, usrId, group);
      else {
        String groupName = await getGroupNameById(group);
        displayError(
            "You've been invited to join the group $groupName, but you're already in that group",
            context);
      }
    } else
      print("link null 1");
  }
}
