import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/utils/oauth.dart';
import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils.dart';
import '../group/group_picker.dart';
import '../Routes/join_group.dart';

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
        builder: (BuildContext context, AsyncSnapshot<bool> isInGroup) {
          return Visibility(
                visible: visible,
                child: Card(
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.mail, color: Colors.white,),
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        "You've been invited to join : ",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    FutureBuilder<String>(
                                        future: getGroupNameById(this.widget.group),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> groupName) {
                                          if (groupName.hasData)
                                            return Text(
                                              groupName.data,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            );
                                          else
                                            return Text(
                                              "...",
                                              style: TextStyle(color: Colors.white),
                                            );
                                        }),
                                  ]),
                              if (isInGroup.data == true)
                                Text(
                                  "But you're already in that group",
                                  style: TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              if (isInGroup.data == false)
                                showInvite(context, this.widget.group,
                                    this.widget.usrId);
                              setState(() {
                                visible = false;
                              });
                            },
                            icon: Icon((isInGroup.data == true)
                                ? Icons.close
                                : Icons.east))
                      ],
                    )),
              );
        });
  }
}

class InvitationPopUp extends StatefulWidget {
  final String group;
  final String usrId;

  InvitationPopUp({this.group, this.usrId});

  @override
  _InvitationPopUpState createState() => _InvitationPopUpState();
}

class _InvitationPopUpState extends State<InvitationPopUp> {
  @override
  Widget build(BuildContext context) {
    return Card(
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.mail, color: Colors.white),
                            ),
                            Text(
                              "You've been invited !",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ]),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16,),
              FutureBuilder<String>(
                  future: getGroupNameById(this.widget.group),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> groupName) {
                    if (groupName.hasData)
                      return RichText(
                        text: TextSpan(
                          text: 'Join ',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(text: groupName.data, style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' ?'),
                          ],
                        ),
                      );
                    else
                      return Text(
                        "...",
                        style: TextStyle(color: Colors.white),
                      );
                  }),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                    child: Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    onPressed: () async {
                      bool success = false;
                      if (await groupExist(this.widget.group)) if (await addGroup(this.widget.group, this.widget.usrId))
                        success = true;
                      checkGroup(await getUserById(this.widget.usrId), this.widget.group);
                      Navigator.of(context).pop();
                      showFlushBar(
                          success
                              ? "You've been added to the group"
                              : "An error occured",
                          success ? Colors.green : Colors.red,
                          success ? Icons.info_outline : Icons.error_outline,
                          context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                    child: Text("No", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ]),
            ],
          ),
        ));
  }
}

Future<void> showInvite(
    BuildContext context, String group, String usrId) async {
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
              if (await groupExist(group)) if (await addGroup(group, usrId))
                success = true;
              checkGroup(await getUserById(usrId), group);
              Navigator.of(context).pop();
              showFlushBar(
                  success
                      ? "You've been added to the group"
                      : "An error occured",
                  success ? Colors.green : Colors.red,
                  success ? Icons.info_outline : Icons.error_outline,
                  context);
            },
          ),
        ],
      );
    },
  );
}


void showInvitation(BuildContext context, String usrId, String group) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            InvitationPopUp(
              group: group,
              usrId: usrId,
            )
          ]),
        ],
      );
    },
  );
}
