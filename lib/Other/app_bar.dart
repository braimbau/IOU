import 'dart:io';

import 'package:deed/utils/error.dart';
import 'package:deed/Routes/join_group.dart';
import 'package:flutter/services.dart';

import '../Utils.dart';
import '../group/group_menu.dart';
import '../group/group_picker.dart';
import '../Routes/log_screen.dart';
import '../classes/user.dart';
import 'user_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget topAppBar(IOUser usr, String group, BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.west,
            color: Colors.white,
          ),
          iconSize: 30,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: group));
                  displayMessage("Group Id succesffully pasted in clipboard !", context);
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
        UserDisplay(usr: usr, group: group),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    ),
    backgroundColor: Colors.grey[850],
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
