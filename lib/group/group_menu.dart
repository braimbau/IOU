import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/classes/user.dart';
import 'package:deed/utils/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../Utils.dart';
import 'group_picker.dart';

class GroupMenu extends StatefulWidget {
  final IOUser usr;
  final String excludeGroup;
  final Map<String, String> groupMap;

  GroupMenu({this.usr, this.excludeGroup, this.groupMap});

  @override
  _GroupMenuState createState() => _GroupMenuState();
}

class _GroupMenuState extends State<GroupMenu> {
  IOUser usr;
  String group;
  Map<String, String> groupMap;

  @override
  Widget build(BuildContext context) {
    usr = this.widget.usr;
    group = this.widget.excludeGroup;
    groupMap = this.widget.groupMap;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.white,
            width: 1,
          ),
        ),
        color: Colors.grey[850],
        child: SizedBox(
          width: 175,
          height: 210,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    FavGroup(usrId: usr.getId(), group: group),
                    Flexible(
                      child: FittedBox(
                        child: Text(
                          groupMap[group],
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.ios_share),
                        onPressed: () async {
                          String url = await getGroupDynamicLink(group);
                          await Share.share(url);
                        }),
                  ]),
                  Expanded(
                    child: GroupPicker(
                      usr: usr,
                      excludeGroup: this.widget.excludeGroup,
                      groupMap: groupMap,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      confirmLeaveGroup(context, usr.getId(), group);
                    },
                    child: Text(
                      'Leave group',
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(), primary: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

class FavGroup extends StatelessWidget {
  final String usrId;
  final String group;

  FavGroup({this.usrId, this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(usrId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) return Container();
          return IconButton(
              icon: Icon((snapshot.data["defaultGroup"] == group)
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () async {
                await toggleDefaultGroup(usrId, group);
              });
        });
  }
}

confirmLeaveGroup(BuildContext context, String usrId, String group) {
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
              Navigator.of(context).popUntil(ModalRoute.withName('/mainPage'));
              if (err != null)
                displayError(err, context);
              else
                Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
