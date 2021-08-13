import 'dart:io' show Platform;

import 'package:deed/Routes/join_group.dart';
import 'package:deed/Utils.dart';
import 'package:deed/utils/error.dart';
import 'package:deed/utils/themes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../main.dart';
import '../main.dart';
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
  void initState() {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      await handleDynamicLink(dynamicLink, context);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    String groupInvite = this.widget.args;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: groupInvite != null && groupInvite != "",
                child: IconButton(
                  onPressed: () {
                    displayMessage("Log in to accept the invitation", context);
                  },
              icon: Icon(Icons.mail, color: Colors.orange,),
            )),
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
              Navigator.pushReplacementNamed(context, '/joinGroup',
                  arguments: JoinGroupArgs(usr: usr, groupInvite: groupInvite));
            },
          ),
          SignInButton(
            Buttons.Google,
            onPressed: () async {
              IOUser usr = await signInWithGoogle();
              Navigator.pushReplacementNamed(context, '/joinGroup',
                  arguments: JoinGroupArgs(usr: usr, groupInvite: groupInvite));
            },
          ),
          Flexible(
            child: SizedBox(
              height: 100,
            ),
          )
        ],
      ),
    );
  }
}
