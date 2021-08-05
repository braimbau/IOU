import 'dart:io';

import 'package:deed/error.dart';
import 'package:deed/join_group.dart';

import 'Utils.dart';
import 'group_menu.dart';
import 'group_picker.dart';
import 'log_screen.dart';
import 'user.dart';
import 'user_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget topAppBar(IOUser usr, String group, BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        UserDisplay(usr: usr, group: group),
        FutureBuilder<Map<String, String>>(
            future: getUserGroupsMap(usr.getId()),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, String>> groupMap) {
              return InkWell(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                onTap: () {
                  if (groupMap.hasData)
                  showGroupPicker(context, usr, group, groupMap.data);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(children: [
                        Icon(Icons.expand_more),
                        Text((groupMap.hasData) ? groupMap.data[group] : "...", style: TextStyle(fontSize: 25),)
                      ]),
                    )),
              );
            }),
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Colors.red,
          ),
          iconSize: 30,
          onPressed: () {
            confirmLeaveGroup(context, usr.getId(), group);
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    ),
    backgroundColor: Colors.grey[850],
  );
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

void showGroupPicker(BuildContext context, IOUser usr, String group, Map<String, String> groupMap) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext contextOfDialog) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            GroupMenu(
              usr: usr,
              excludeGroup: group,
              groupMap: groupMap,
            )
          ]),
        ],
      );
    },
  );
}
