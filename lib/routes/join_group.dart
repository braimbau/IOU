import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/group/group_creation.dart';
import 'package:deed/Other/invitation.dart';
import 'package:deed/group/manual_join.dart';
import 'package:deed/utils/error.dart';
import 'package:deed/utils/logo.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils.dart';
import '../group/group_selection.dart';
import '../main.dart';
import 'main_page.dart';
import '../classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class JoinGroupArgs {
  IOUser usr;
  String groupInvite;

  JoinGroupArgs({this.usr, this.groupInvite});
}

class JoinGroup extends StatefulWidget {
  final JoinGroupArgs args;

  JoinGroup({this.args});

  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {

  @override
  void initState() {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          await handleDynamicLink(dynamicLink, context);
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var t = AppLocalizations.of(context);

    IOUser usr = this.widget.args.usr;
    String groupInvite = this.widget.args.groupInvite;

     if (groupInvite == null || groupInvite == "") {
      SchedulerBinding.instance.addPostFrameCallback(
              (_) async => handleRedirection(context, usr));
    }

    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
              Logo(),
              InkWell(
                customBorder: CircleBorder(),
                onTap: () {
                  displayError(t.editProfileOnlyGroup, context);
                },
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 20,
                  child: CircleAvatar(
                      radius: 18, backgroundImage: NetworkImage(usr.getUrl())),
                ),
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
              child: Text(t.joinGroupManually, style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),),
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
      ),
    );
  }
}

Future<String> createGroupT(String groupName, String creatorId, AppLocalizations t) async {
  return await FirebaseFirestore.instance
      .runTransaction((Transaction tr) async {
    final DocumentReference ref =
    FirebaseFirestore.instance.collection("groups").doc();
    String group = ref.id;
    tr.set(ref, {'name': groupName, 'creationDate': DateTime.now().millisecondsSinceEpoch, 'creator' : creatorId});
    return group;
  }).then((value) {
    print("__$value");
    return value;
  }).catchError((error) {
    print(t.transactionError + error);
    return null;
  }).timeout(Duration(seconds: 1), onTimeout: () {return null;});
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

Future<void> logOut(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("userId", null);
  Navigator.of(context).pushReplacementNamed('/logScreen');
}
