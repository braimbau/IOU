import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/Routes/join_group.dart';
import 'package:deed/utils/error.dart';
import 'package:deed/Other/invitation.dart';
import 'package:deed/Routes/main_page.dart';
import 'package:deed/utils/error_screen.dart';
import 'package:deed/utils/loading.dart';
import 'package:deed/utils/themes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Routes/log_screen.dart';
import 'package:provider/provider.dart';

import 'classes/user.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themProvider.themeMode,
          theme: MyThemes.light,
          darkTheme: MyThemes.dark,
          title: 'IOU',
          initialRoute: '/',
          routes: {
            '/': (context) => Home(),
            '/logScreen': (context) =>
                LogScreen(args: ModalRoute.of(context).settings.arguments),
            '/joinGroup': (context) => JoinGroup(
                  args: ModalRoute.of(context).settings.arguments,
                ),
            '/mainPage': (context) => MainPage(
                  args: ModalRoute.of(context).settings.arguments,
                ),
          },
        );
      });
}

class Home extends StatefulWidget {
  final String args;

  Home({this.args});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    SchedulerBinding.instance
        .addPostFrameCallback((_) async => handleInitialization(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Loading();
  }

  Future<InitArgs> globalInitialization() async {
    InitArgs args = InitArgs();
    Firebase.initializeApp();
   // FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false,);
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
      args.setGroupInvitation(deepLink.queryParameters['group']);
    }
    //auto log
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("userId");
    if (await userExist(id)) args.setUsr(await getUserById(id));
    return args;
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
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => LogScreen(args: group,),
            transitionDuration: Duration(seconds: 0),
          ),
        );
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

  void handleInitialization(BuildContext context) async {
    print("yo");
    InitArgs args = await globalInitialization();

    if (args.getUsr() != null) {
      print("Auto logged in as ${args.getUsr().getName()}");
      Navigator.pushNamed(context, '/joinGroup',
          arguments: JoinGroupArgs(
              usr: args.getUsr(), groupInvite: args.getGroupInvitation()));
    }
    else {
      print ("No logs stored, show log page");
      Navigator.pushNamed(
          context, '/logScreen', arguments: args.getGroupInvitation());
    }
  }
}

class InitArgs {
  String _groupInvitation;
  IOUser _usr;

  InitArgs() {
    _groupInvitation = null;
    _usr = null;
  }

  void setGroupInvitation(String groupInvitation) {
    _groupInvitation = groupInvitation;
  }

  void setUsr(IOUser usr) {
    _usr = usr;
  }

  String getGroupInvitation() {
    return _groupInvitation;
  }

  IOUser getUsr() {
    return _usr;
  }
}
