import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/invitation.dart';
import 'package:flutter/scheduler.dart';
import 'Utils.dart';
import 'app_bar.dart';
import 'error_screen.dart';
import 'group_picker.dart';
import 'loading.dart';
import 'main_page.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'error.dart';

class JoinGroup extends StatelessWidget {
  final IOUser usr;
  final String groupInvite;
  final String defaultGroup;

  JoinGroup({this.usr, this.groupInvite, this.defaultGroup});

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => {
          if (defaultGroup != null)
            goMainPageWithGroup(context, usr, defaultGroup)
        });

    String group;
    String groupName;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(),
            flex: 1,
          ),
          if (groupInvite != null)
            InvitationPanel(
              group: groupInvite,
              usrId: usr.getId(),
            ),
          Text(
            "Join a group",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: 'Group code',
                          fillColor: Colors.white,
                          filled: true),
                      onChanged: (String str) {
                        group = str;
                      }),
                ),
                IconButton(
                    icon: Icon(
                      Icons.east,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (await groupExist(group)) addGroup(group, usr.getId());
                      checkGroup(usr, group);
                    }),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            "Create a new group",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: 'Group name',
                          fillColor: Colors.white,
                          filled: true),
                      onChanged: (String str) {
                        groupName = str;
                      }),
                ),
                IconButton(
                    icon: Icon(
                      Icons.east,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      String groupId = await createGroup(groupName);
                      displayMessage('Group $groupName is created', context);
                      addGroup(groupId, usr.getId());
                      checkGroup(usr, groupId);
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
                    }),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: GroupSelection(
              usr: usr,
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> createGroup(String groupName) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("groups").doc();
  String group = document.id;
  await document.set({'name': groupName});
  return group;
}

Future<bool> addGroup(String group, String userId) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("users").doc(userId);
  var doc = await document.get();
  String groups = doc["groups"];
  List<String> groupList =
      (groups == null || groups == "") ? [] : groups.split(":");
  if (groupList.contains(group)) {
    return (false);
  } else {
    groupList.add(group);
    document.update({
      'groups': (groupList.length == 1) ? groupList[0] : groupList.join(":")
    });
    return true;
  }
}

Future<bool> setDefaultGroup(String group, String userId) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("users").doc(userId);
  var doc = await document.get();
  String groups = doc["groups"];
  List<String> groupList =
      (groups == null || groups == "") ? [] : groups.split(":");
  if (!groupList.contains(group)) {
    groupList.add(group);
    document.update({
      'groups': (groupList.length == 1) ? groupList[0] : groupList.join(":")
    });
  }
  document.update({'defaultGroup': group});
  return true;
}

Future<void> sendGroupCode(String code) async {
  if (await groupExist(code)) return;
}

void showFlushBar(
    String text, Color color, IconData icon, BuildContext context) {
  Flushbar(
    message: text,
    backgroundColor: color,
    borderRadius: BorderRadius.all(Radius.circular(50)),
    icon: Icon(
      Icons.error_outline,
      size: 28,
      color: Colors.white,
    ),
    duration: Duration(seconds: 2),
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
  )..show(context);
}

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
                      itemCount: groupList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0),
                      itemBuilder: (BuildContext context, int index) {
                        String groupId = groupList[index];
                        return InkWell(
                          onTapCancel: () {
                            toggleDefaultGroup(usr.getId(), groupId);
                          },
                          onTap: () {
                            if (groupMap.containsKey(groupId))
                              goMainPageWithGroup(context, usr, groupId);
                          },
                          onLongPress: () {
                            _confirmLeaveGroup(context, usr.getId(), groupId);
                          },
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                alignment: Alignment.center,
                                child: FittedBox(
                                    child: Text(groupMap.containsKey(groupId)
                                        ? groupMap[groupId]
                                        : "...")),
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
                        );
                      }),
                );
              });
        });
  }
}

Future<void> goMainPageWithGroup(
    BuildContext context, IOUser usr, String group) async {
  await checkGroup(usr, group);
  await updateUserInfosFromGroup(usr, group);
  Navigator.pushNamed(context, '/mainPage',
      arguments: MainPageArgs(usr: usr, group: group));
}

_confirmLeaveGroup(BuildContext context, String usrId, String group) {
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
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Leave'),
            onPressed: () async {
              String err = await leaveGroup(usrId, group);
              Navigator.of(context).pop();
              if (err != null) displayError(err, context);
            },
          ),
        ],
      );
    },
  );
}
