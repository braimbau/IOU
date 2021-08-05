import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'Utils.dart';
import 'error.dart';
import 'error_screen.dart';
import 'loading.dart';
import 'main_page.dart';

class GroupSelection extends StatelessWidget {
  final IOUser usr;
  final String excludeGroup;

  GroupSelection({this.usr, this.excludeGroup});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(usr.getId())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorScreen('Something went wrong with groups');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          String groups = snapshot.data["groups"];
          String defaultGroup = snapshot.data["defaultGroup"];

          List<String> groupList =
              (groups == "" || groups == null) ? [] : groups.split(':');

          if (excludeGroup != null) groupList.remove(excludeGroup);

          return FutureBuilder<Map<String, String>>(
              future: getGroupsMap(groupList),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, String>> groupMapSnap) {
                var groupMap = groupMapSnap.data;
                return Visibility(
                  visible: groupMapSnap.hasData,
                  child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: groupList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0),
                      itemBuilder: (BuildContext context, int index) {
                        String groupId = groupList[index];
                        return GestureDetector(
                          onPanUpdate: (details) {
                            if (details.delta.dx.abs() > 15)
                              _confirmLeaveGroup(context, usr.getId(), groupId);
                          },
                          child: InkWell(
                            onTap: () {
                              if (groupMap.containsKey(groupId))
                                goMainPageWithGroup(context, usr, groupId);
                            },
                            onLongPress: () {
                              toggleDefaultGroup(usr.getId(), groupId);
                            },
                            child: Stack(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                      child: Text(
                                    groupMap.containsKey(groupId)
                                        ? groupMap[groupId]
                                        : "...",
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
                                  visible: defaultGroup == groupId,
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
      return AlertDialog(
        title: Text('Leave group'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Are you sure you want to leave this group ?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              if (spam == false) spam = true;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Leave'),
            onPressed: () async {
              if (spam == false) {
                spam = true;
                String err = await leaveGroup(usrId, group);
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
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
  await updateUserInfosFromGroup(usr, group);
  Navigator.pushNamed(context, '/mainPage',
      arguments: MainPageArgs(usr: usr, group: group));
}
