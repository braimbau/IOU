import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import '../Utils.dart';
import '../utils/error.dart';
import '../utils/error_screen.dart';
import '../classes/group.dart';
import '../utils/loading.dart';
import '../Routes/main_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupSelection extends StatelessWidget {
  final IOUser usr;
  final String excludeGroup;

  GroupSelection({this.usr, this.excludeGroup});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context);

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(usr.getId())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorScreen(t.err1);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          String groups = snapshot.data["groups"];
          String defaultGroup = snapshot.data["defaultGroup"];

          List<String> stringGroupList =
              (groups == "" || groups == null) ? [] : groups.split(':');

          if (excludeGroup != null) stringGroupList.remove(excludeGroup);

          if (stringGroupList.isEmpty)
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                Text(t.nothingDisplay, style: TextStyle(color: Colors.red),),
              Text(t.createJoin, style: TextStyle(color: Colors.red),),
              ],
              ),
            );
          return FutureBuilder<List<Group>>(
              future: getGroupsById(stringGroupList),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Group>> groupListSnap) {
                List<Group> groupList = groupListSnap.data;
                return Visibility(
                  visible: groupListSnap.hasData,
                  child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: stringGroupList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= groupList.length)
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: FittedBox(
                                  child: Text("...",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                          );
                        Group group = groupList[index];
                        return GestureDetector(
                          onPanUpdate: (details) {
                            if (details.delta.dx.abs() > 15)
                              _confirmLeaveGroup(context, usr.getId(), group.getId());
                          },
                          child: InkWell(
                            onTap: () {
                                goMainPageWithGroup(context, usr, group.getId());
                            },
                            onLongPress: () {
                              toggleDefaultGroup(usr.getId(), group.getId());
                            },
                            child: Stack(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                      child: Text(group.getName(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )),
                                  decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                              Visibility(
                                  visible: defaultGroup == group.getId(),
                                  child: Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Icon(
                                      Icons.favorite,
                                      size: 25,
                                      color: Colors.blue,
                                    ),
                                  )),
                            ]),
                          ),
                        );
                      }),
                );
              });
        });
  }
}

_confirmLeaveGroup(BuildContext context, String usrId, String group) {
  bool spam = false;
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      AppLocalizations t = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(t.leaveGroup),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(t.confirmLeaveGroup),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(t.cancel),
            onPressed: () {
              if (spam == false) spam = true;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(t.leave),
            onPressed: () async {
              if (spam == false) {
                spam = true;
                String err = await leaveGroup(usrId, group, context);
                Navigator.of(context).popUntil(ModalRoute.withName('/joinGroup'));
                if (err != null) displayError(err, context);
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> goMainPageWithGroup(
    BuildContext context, IOUser usr, String group) async {
  Navigator.pushNamed(context, '/mainPage',
      arguments: MainPageArgs(usr: usr, group: group));
}
