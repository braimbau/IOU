import 'package:deed/Routes/join_group.dart';
import 'package:deed/classes/user_prefs.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'classes/user.dart';
import 'other/update_screen.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  UserPrefs usrPrefs = UserPrefs();
  usrPrefs.get(prefs);
  runApp(MyApp(userPrefs: usrPrefs,));
}

class MyApp extends StatelessWidget {
  final UserPrefs userPrefs;

  MyApp({this.userPrefs});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''), // English, no country code
            Locale('fr', ''), // french, no country code
          ],
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
    /*FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      await handleDynamicLink(dynamicLink, context);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    }); */

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

  void handleInitialization(BuildContext context) async {
    InitArgs args = await globalInitialization();
    if (!await isVersionUpToDate()) {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, animation1, animation2) => UpdateScreen()));
      return;
    }

    if (args.getUsr() != null) {
      print("Auto logged in as ${args.getUsr().getName()}");
      Navigator.pushReplacementNamed(context, '/joinGroup',
          arguments: JoinGroupArgs(
              usr: args.getUsr(), groupInvite: args.getGroupInvitation()));
    }
    else {
      print ("No logs stored, show log page");
      Navigator.pushReplacementNamed(
          context, '/logScreen', arguments: args.getGroupInvitation());
    }
  }
}

Future<void> handleDynamicLink(
    PendingDynamicLinkData dynamicLink,
    BuildContext context,
    ) async {
  final Uri deepLink = dynamicLink?.link;
  AppLocalizations t = AppLocalizations.of(context);

  if (deepLink != null) {
    String group = deepLink.queryParameters['group'];
    if (!await groupExist(group)) {
      displayError(t.groupDeletedErr, context);
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String usrId = prefs.getString("userId");
    if (usrId == null) {
      Navigator.pushReplacementNamed(context, '/logScreen', arguments: group);
      return;
    }
    print(
        "is in group ${await userIsInGroup(group, usrId)}, group $group usrid $usrId");
    if (await userIsInGroup(group, usrId) == false)
      showInvitation(context, usrId, group);
    else {
      String groupName = await getGroupNameById(group);
      displayError(
          t.invitationTo + groupName + ", " + t.alreadyInGroup,
          context);
    }
  } else
    print("link null 1");
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
