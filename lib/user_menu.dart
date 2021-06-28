import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'log_screen.dart';

class UserMenu extends StatefulWidget {
  final IOUser usr;
  final BuildContext context;

  UserMenu({this.usr, this.context});

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  bool editableMode = false;
  String newName = "";

  @override
  Widget build(BuildContext context) {
    IOUser usr = this.widget.usr;
    BuildContext context = this.widget.context;

    return Card(
        color: Colors.grey,
        child: SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(children: [
                  Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(usr.getUrl())))),
                  Flexible(
                    child: (editableMode)
                        ? TextField(
                            onChanged: (String txt) {
                              newName = txt;
                            },
                          )
                        : RichText(
                            text: TextSpan(children: [
                            TextSpan(text: 'Logged in as\n'),
                            TextSpan(
                                text: usr.getName(),
                                style: TextStyle(fontWeight: FontWeight.bold))
                          ])),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  LogScreen(),
                              transitionDuration: Duration(seconds: 0)),
                        );
                      },
                      child: Text((editableMode) ? 'Cancel' : 'Log out'),
                      style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(), primary: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          if (editableMode) if (newName != "")
                            changeName(usr.getId(), newName);
                          else
                            newName = "";
                          editableMode = !editableMode;
                        });
                      },
                      child: Text((editableMode) ? 'Confirm' : 'Edit'),
                      style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

Future<void> changeName(String id, String name) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  ref.doc(id).update({"name": name});
}
