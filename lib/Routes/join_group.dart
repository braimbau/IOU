import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/Other/user_display.dart';
import 'package:deed/Other/user_menu.dart';
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

class JoinGroupArgs {
  IOUser usr;
  String groupInvite;

  JoinGroupArgs({this.usr, this.groupInvite});
}

class JoinGroup extends StatelessWidget {
  final JoinGroupArgs args;

  JoinGroup({this.args});

  @override
  Widget build(BuildContext context) {
    IOUser usr = args.usr;
    String groupInvite = args.groupInvite;
    print("group invitation : $groupInvite");

    SchedulerBinding.instance.addPostFrameCallback(
        (_) async => handleRedirection(context, usr));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              iconSize: 30,
              onPressed: () async {
                await logOut(context);
              }
            ),
            Center(child: Image.asset((Theme.of(context).brightness == Brightness.dark) ? 'asset/image/logo_dark.png' : 'asset/image/logo_light.png', height: 45)),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 20,
              child: CircleAvatar(
                  radius: 18, backgroundImage: NetworkImage(usr.getUrl())),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Container(),
          if (groupInvite != null)
            InvitationPanel(
              group: groupInvite,
              usrId: usr.getId(),
            ),
          SizedBox(
            height: 50,
          ),
          GroupCreation(
            usr: usr,
          ),
          TextButton(
            onPressed: () {
              showManualJoin(context, usr);
            },
            child: Text("join group manually", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
          Text("My groups:", style: Theme.of(context).textTheme.headline2,),
          Flexible(
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
  Navigator.pushNamed(context, '/mainPage',
      arguments: MainPageArgs(usr: usr, group: group));
}

Future<void> handleRedirection(
    BuildContext context, IOUser usr) async {
  String defaultGroup = await getDefaultGroup(usr.getId());
  if (defaultGroup == null || defaultGroup == "") return;
  if (await groupExist(defaultGroup) &&
      await userIsInGroup(defaultGroup, usr.getId()))
    await goMainPageWithGroup(context, usr, defaultGroup);
  else
    await setDefaultGroup(usr.getId(), null);
}
