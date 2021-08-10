import 'dart:io' show Platform;

import 'package:deed/Routes/join_group.dart';
import 'package:deed/Utils.dart';
import 'package:deed/utils/error.dart';
import 'package:deed/utils/themes.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../utils/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/error_screen.dart';
import '../utils/oauth.dart';
import 'main_page.dart';
import '../classes/user.dart';

class LogScreen extends StatefulWidget {
  final String args;

  LogScreen({this.args});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    String groupInvite = this.widget.args;

    SchedulerBinding.instance
        .addPostFrameCallback((_) async => handleAutoLogIn(context));
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ChangeThemeButtonWidget(),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Welcome to",
            style: Theme.of(context).textTheme.headline1,
          )),
          Center(
              child: Image.asset(
                  (Theme.of(context).brightness == Brightness.dark)
                      ? 'asset/image/IOU_dark.png'
                      : 'asset/image/IOU_light.png',
                  height: 150)),
          if (Platform.isIOS)
            SignInButton(
            Buttons.Apple,
            onPressed: () async {
              IOUser usr = await signInWithApple();
              Navigator.pushNamed(context, '/joinGroup',
                  arguments: JoinGroupArgs(usr: usr, groupInvite: groupInvite));
            },
          ),
          SignInButton(
            Buttons.Google,
            onPressed: () async {
              IOUser usr = await signInWithGoogle();
              Navigator.pushNamed(context, '/joinGroup',
                  arguments: JoinGroupArgs(usr: usr, groupInvite: groupInvite));
            },
          ),
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}

Future<void> handleAutoLogIn(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String id = prefs.getString("userId");
  if (id != null && id != "") {
    IOUser usr = await getUserById(id);
    Navigator.pushNamed(context, '/joinGroup',
        arguments: JoinGroupArgs(usr: usr));
  }
}
