import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/image_import.dart';
import 'package:deed/oauth.dart';
import 'package:deed/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'image_import.dart';
import 'dart:io';

import 'image_import.dart';
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
  String newName;
  File img;

  @override
  Widget build(BuildContext context) {
    IOUser usr = this.widget.usr;
    BuildContext context = this.widget.context;
    newName = usr.getName();

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
                      child: InkWell(
                        customBorder: CircleBorder(),
                        onTap: () async {
                          if (editableMode) img = await pickImage();
                          setState(() {});
                        },
                        child: Stack(children: [
                          CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: (img != null)
                                      ? FileImage(img)
                                      : NetworkImage(usr.getUrl()))),
                          if (editableMode)
                            Positioned(
                              child: Icon(Icons.edit, size: 20),
                              right: 4,
                              bottom: 4,
                            ),
                        ]),
                      )),
                  Flexible(
                    child: (editableMode)
                        ? TextFormField(
                            initialValue: usr.getName(),
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
                        if (!editableMode)
                          logOut(context);
                        else
                          img = null;
                        setState(() {
                          editableMode = !editableMode;
                        });
                      },
                      child: Text((editableMode) ? 'Cancel' : 'Log out'),
                      style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(), primary: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (editableMode) {
                          if (newName != "") {
                            changeName(usr.getId(), newName);
                            if (img != null) {
                              String url =
                                  await uploadImageToFirebase(img, usr.getId());
                              changeUrl(usr.getId(), url);
                            }
                            logOut(context);
                          } else
                            Flushbar(
                              message: "You can't have an empty name",
                              backgroundColor: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              icon: Icon(
                                Icons.error_outline,
                                size: 28,
                                color: Colors.white,
                              ),
                              duration: Duration(seconds: 2),
                              forwardAnimationCurve:
                                  Curves.fastLinearToSlowEaseIn,
                            )..show(context);
                        } else {
                          newName = usr.getName();
                        }
                        setState(() {
                          editableMode = !editableMode;
                        });
                      },
                      child: Text((editableMode) ? 'Confirm' : 'Edit'),
                      style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                    ),
                  ],
                ),
                if (editableMode)
                  Text(
                    "You'll be log out to apply the profil changes",
                    style: TextStyle(color: Colors.white, fontSize: 10),
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

void logOut(BuildContext context) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LogScreen(),
        transitionDuration: Duration(seconds: 0)),
  );
}
