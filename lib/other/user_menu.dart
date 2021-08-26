import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/utils/error.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils.dart';
import '../group/group_picker.dart';
import '../utils/image_import.dart';
import '../main.dart';
import '../Routes/main_page.dart';
import '../utils/oauth.dart';
import '../classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/image_import.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../utils/image_import.dart';
import '../Routes/log_screen.dart';

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
    AppLocalizations t = AppLocalizations.of(context);

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1,
          ),
        ),
        child: SizedBox(
          width: 240,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Expanded(
                    child: Center(
                      child: (btnMode != 0)
                          ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextFormField(
                                maxLength: 20,
                                initialValue: usr.getName(),
                                onChanged: (String txt) {
                                  if (newName.characters.length == 20 && txt.characters.length == 20)
                                    displayError(t.maxLengthUserName, context);
                                  newName = txt;
                                },
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  counterText: '',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey[500]),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                )),
                          )
                          : Align(
                        alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: RichText(
                                  text: TextSpan(children: [
                                  TextSpan(
                                      text: t.loggedAs,
                                      style: Theme.of(context).textTheme.bodyText1),
                                  TextSpan(
                                      text: usr.getName(),
                                      style: Theme.of(context).textTheme.bodyText2)
                                ])),
                            ),
                          ),
                    ),
                  ),
                  InkWell(
                    customBorder: CircleBorder(),
                    onTap: () async {
                      if (btnMode == 1) img = await pickImage();
                      setState(() {});
                    },
                    child: Stack(children: [
                      CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context).primaryColor,
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
                  ),
                ]),
                SizedBox(
                  height: 8,
                  child: Container(),
                ),
                Visibility(
                  visible: btnMode == 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            logOut(context);
                          },
                          child: SizedBox(
                              width: 60, child: Center(child: Text(t.logout))),
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
                              width: 60, child: Center(child: Text(t.edit))),
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
                          child: SizedBox(
                              width: 60, child: Center(child: Text(t.cancel))),
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), primary: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (newName == "") {
                              displayError(
                                  t.emptyNameErr, context);
                              return;
                            }

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
                            Navigator.pushReplacementNamed(context, '/mainPage', arguments: MainPageArgs(
                                usr: usr, group: this.widget.group));
                          },
                          child: SizedBox(
                              width: 60, child: Center(child: Text(t.confirm))),
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
                          child: SizedBox(
                              width: 60, child: Center(child: Text('...'))),
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), onSurface: Colors.white),
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
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), onSurface: Colors.white),
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

Future<void> logOut(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("userId", null);
  Navigator.of(context).popUntil(ModalRoute.withName('/'));
  Navigator.pushNamed(context, '/logScreen');
}
