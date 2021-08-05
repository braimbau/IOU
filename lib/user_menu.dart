import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/error.dart';
import 'Utils.dart';
import 'group_picker.dart';
import 'image_import.dart';
import 'main.dart';
import 'main_page.dart';
import 'oauth.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'image_import.dart';
import 'dart:io';

import 'image_import.dart';
import 'log_screen.dart';

class UserMenu extends StatefulWidget {
  final IOUser usr;
  final BuildContext context;
  final String group;

  UserMenu({this.usr, this.context, this.group});

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  int btnMode = 0; // 0: classic 1: edit 2: loading
  String newName;
  File img;

  void toggleBtnMode() {
    if (btnMode == 1)
      btnMode = 0;
    else
      btnMode = 1;
  }

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
                          if (btnMode == 1) img = await pickImage();
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
                          if (btnMode == 1)
                            Positioned(
                              child: Icon(Icons.edit, size: 20),
                              right: 4,
                              bottom: 4,
                            ),
                        ]),
                      )),
                  Flexible(
                    child: (btnMode != 0)
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
                Visibility(
                  visible: btnMode == 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            logOut(context);
                          },
                          child: SizedBox(width: 60, child: Center(child: Text('Log out'))),
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), primary: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              newName = usr.getName();
                              toggleBtnMode();
                            });
                          },
                          child: SizedBox(
                              width: 60, child: Center(child: Text('Edit'))),
                          style:
                              ElevatedButton.styleFrom(shape: StadiumBorder()),
                        ),
                      ]),
                ),
                Visibility(
                  visible: btnMode == 1,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            img = null;
                            setState(() {
                              toggleBtnMode();
                            });
                          },
                          child: SizedBox(width: 60, child: Center(child: Text('Cancel'))),
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), primary: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (newName != "") {
                              setState(() {
                                btnMode = 2;
                              });
                              await changeName(
                                  usr.getId(), newName, this.widget.group);
                              usr.setName(newName);
                              if (img != null) {
                                String url = await uploadImageToFirebase(
                                    img, usr.getId() + this.widget.group);
                                print(url);
                                usr.setUrl(url);
                                await changePhotoUrl(
                                    usr.getId(), url, this.widget.group);
                              }
                              Navigator.of(context)
                                  .popUntil(ModalRoute.withName('/mainPage'));
                              Navigator.pushReplacementNamed(
                                  context, '/mainPage',
                                  arguments: MainPageArgs(
                                      usr: usr, group: this.widget.group));
                            } else
                              displayError(
                                  "You can't have an empty name", context);
                          },
                          child: SizedBox(width: 60, child: Center(child: Text('Confirm'))),
                          style:
                              ElevatedButton.styleFrom(shape: StadiumBorder()),
                        ),
                      ]),
                ),
                Visibility(
                  visible: btnMode == 2,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          child: SizedBox(width: 60, child: Center(child: Text('...'))),
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), primary: Colors.red),
                        ),
                        ElevatedButton(
                          child: SizedBox(
                              width: 60,
                              child: Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                            value: null,
                            semanticsLabel: 'Linear progress indicator',
                          ),
                                ),
                              )),
                          style:
                          ElevatedButton.styleFrom(shape: StadiumBorder(), primary: Colors.blue),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ));
  }
}

Future<void> changeName(String id, String name, String group) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('groups');
  ref.doc(group).collection("users").doc(id).update({"name": name});
}

void logOut(BuildContext context) {
  Navigator.of(context).popUntil(ModalRoute.withName('/mainPage'));
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => Home(),
        transitionDuration: Duration(seconds: 0)),
  );
}
