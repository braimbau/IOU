import 'package:deed/Routes/join_group.dart';
import 'package:deed/Utils.dart';
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

    SchedulerBinding.instance.addPostFrameCallback(
            (_) async => handleAutoLogIn(context));

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Welcome to",
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          )),
          Center(child: Image.asset('asset/image/IOU.png', height: 150)),
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
