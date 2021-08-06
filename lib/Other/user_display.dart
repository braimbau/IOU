import 'package:deed/Utils.dart';

import 'user_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/user.dart';

class UserDisplay extends StatelessWidget {
  final IOUser usr;
  final String group;

  UserDisplay({this.usr, this.group});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: updateUserInfosFromGroup(usr, group),
        builder: (BuildContext context, AsyncSnapshot<bool> update) {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: (update.hasData)
                      ? CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(usr.getUrl()))
                      : CircleAvatar()),
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.setString("userId", null);
                prefs.setString("name", null);
                prefs.setString("photoUrl", null);
                showUserMenu(context, usr, group);
              },
            ),
          );
        });
  }
}

void showUserMenu(BuildContext context, IOUser usr, String group) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            UserMenu(
              usr: usr,
              context: context,
              group: group,
            )
          ]),
        ],
      );
    },
  );
}
