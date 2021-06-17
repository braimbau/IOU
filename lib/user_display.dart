import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'log_screen.dart';
import 'user.dart';


class UserDisplay extends StatelessWidget {
  final IOUser usr;

  UserDisplay({this.usr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: InkWell(child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: CircleAvatar(
              radius: 18, backgroundImage: NetworkImage(usr.getUrl()))
      ), onTap: () async {
          final SharedPreferences prefs = await SharedPreferences
              .getInstance();
          prefs.setString("userId", null);
          prefs.setString("name", null);
          prefs.setString("photoUrl", null);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => LogScreen(),
                transitionDuration: Duration(seconds: 0)),
          );
        },
      ),
    );
  }
}
