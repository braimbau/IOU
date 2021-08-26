import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/utils/oauth.dart';
import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils.dart';
import '../group/group_picker.dart';
import '../Routes/join_group.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    AppLocalizations t = AppLocalizations.of(context);

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
                      child: Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  child: Text(
                                    t.invitationTo,
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
                              t.alreadyInGroup,
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          if (isInGroup.data == false)
                            showInvite(
                                context, this.widget.group, this.widget.usrId);
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
    AppLocalizations t = AppLocalizations.of(context);

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
                              t.invited,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ]),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              FutureBuilder<String>(
                  future: getGroupNameById(this.widget.group),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> groupName) {
                    if (groupName.hasData)
                      return RichText(
                        text: TextSpan(
                          text: t.joina,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                                text: groupName.data,
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    child: Text(
                      t.yes,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      String err = await joinGroupT(
                          this.widget.usrId, this.widget.group, context);
                      Navigator.of(context).pop();
                      showFlushBar(
                          (err == null)
                              ? t.groupAdded
                              : err,
                          (err == null) ? Colors.green : Colors.red,
                          (err == null)
                              ? Icons.info_outline
                              : Icons.error_outline,
                          context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    child: Text(
                      "No",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
  AppLocalizations t = AppLocalizations.of(context);

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(t.joinGroupa + "groupName"),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(t.confirmJoinGroup),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(t.no),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(t.yes),
            onPressed: () async {
              String err = await joinGroupT(usrId, group, context);
              Navigator.of(context).pop();
              showFlushBar(
                  (err == null) ? t.groupAdded : err,
                  (err == null) ? Colors.green : Colors.red,
                  (err == null) ? Icons.info_outline : Icons.error_outline,
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
