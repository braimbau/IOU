import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/group/group_creation.dart';
import 'package:deed/Other/invitation.dart';
import 'package:deed/group/manual_join.dart';
import 'package:flutter/scheduler.dart';
import '../Utils.dart';
import '../group/group_selection.dart';
import 'main_page.dart';
import '../classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JoinGroup extends StatelessWidget {
  final IOUser usr;
  final String groupInvite;
  final String defaultGroup;

  JoinGroup({this.usr, this.groupInvite, this.defaultGroup});

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(
        (_) async => handleRedirection(context, usr, defaultGroup));

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
          SizedBox(
            height: 50,
          ),
          GroupCreation(usr: usr,),
          TextButton(onPressed: () {
            showManualJoin(context, usr);
          }, child: Text("join group manually"),),
          Divider(
            color: Colors.white,
          ),
          Expanded(
            flex: 3,
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

Future<void> goMainPageWithGroup(
    BuildContext context, IOUser usr, String group) async {
  print("_____${usr.getUrl()}");
  Navigator.pushNamed(context, '/mainPage',
      arguments: MainPageArgs(usr: usr, group: group));
}

Future<void> handleRedirection(
    BuildContext context, IOUser usr, String defaultGroup) async {
  if (defaultGroup == null || defaultGroup == "") return;
  if (await groupExist(defaultGroup) &&
      await userIsInGroup(defaultGroup, usr.getId()))
    await goMainPageWithGroup(context, usr, defaultGroup);
  else
    await setDefaultGroup(usr.getId(), null);
}
