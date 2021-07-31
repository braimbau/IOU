import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'group_picker.dart';
import 'join_group.dart';

class InvitationPanel extends StatefulWidget {
  final String group;
  final String usrId;

  InvitationPanel({this.group, this.usrId});

  @override
  _InvitationPanelState createState() => _InvitationPanelState();
}

class _InvitationPanelState extends State<InvitationPanel> {
  bool visible;
  bool valid;

  @override
  void initState() {
    visible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: userIsInGroup(this.widget.group, this.widget.usrId),
        builder: (BuildContext context,
            AsyncSnapshot<bool> isInGroup) {
          return visible
              ? Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // if you need this
                side: BorderSide(
                  color: Colors.white,
                  width: 0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              color: Colors.orange,
              semanticContainer: true,
              elevation: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("You've been invited to join the group : ",
                              style: TextStyle(color: Colors.white),),
                            FutureBuilder<String>(
                                future: getGroupNameById(this.widget.group),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> groupName) {
                                  if (groupName.hasData)
                                    return Text(
                                      groupName.data, style: TextStyle(color: Colors
                                        .white, fontWeight: FontWeight.bold),);
                                  else
                                    return Text(
                                      "...", style: TextStyle(color: Colors
                                        .white),);
                                }),
                          ]
                      ),
                      if (isInGroup.data == true)
                        Text("But you're already in that group",
                        style: TextStyle(color: Colors.white),),
                    ],
                  ),
                  IconButton(onPressed: () {
                    if (isInGroup.data == false)
                      showInvite(
                          context, this.widget.group, this.widget.usrId);
                    setState(() {
                      visible = false;
                    });
                  }, icon: Icon((isInGroup.data == true) ? Icons.close : Icons.east))
                ],
              )
          ) : Container ();
        });
  }
}

Future<void> showInvite(BuildContext context, String group,
    String usrId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Join the group groupName'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Are you sure you want to join this group ?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              bool success = false;
              if (await groupExist(group))
                if (await addGroup(group, usrId))
                  success = true;
              Navigator.of(context).pop();
              showFlushBar(success
                  ? "You've been added to the group"
                  : "An error occured", success ? Colors.green : Colors.red,
                  success ? Icons.info_outline : Icons.error_outline, context);
            },
          ),
        ],
      );
    },
  );
}

Future<bool> userIsInGroup(String group, String usrId) async {
  final DocumentReference document =
  FirebaseFirestore.instance.collection("users").doc(usrId)
      .collection("groups")
      .doc(group);
  var doc = await document.get();
  return doc.exists;
}