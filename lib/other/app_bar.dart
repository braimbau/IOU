import 'dart:io';

import 'package:deed/classes/group.dart';
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.west,
            color: Theme.of(context).primaryColor,
          ),
          iconSize: 30,
          onPressed: () {
            Navigator.of(context).popUntil(ModalRoute.withName('/mainPage'));
            Navigator.of(context).pop();
          },
        ),
        Flexible(
          child: FutureBuilder<List<Group>>(
              future: getGroupsByUserId(usr.getId()),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Group>> snap) {
                List<Group> groupList = snap.data;
                String groupName;
                if (snap.hasData)
                  groupName = groupList.firstWhere((element) => element.getId() == group).getName();
                return InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  onTap: () {
                    if (snap.hasData)
                    showGroupPicker(context, usr, group, groupList);
                  },
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: group));
                    displayMessage("Group Id succesffully pasted in clipboard !", context);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(children: [
                            Icon(Icons.expand_more, color: Theme.of(context).primaryColor),
                            Text((snap.hasData) ? groupName : "...", style: Theme.of(context).textTheme.headline2,)
                          ]),
                        ),
                      )),
                );
              }),
        ),
        UserDisplay(usr: usr, group: group),
      ],
    ),
  );
}

void showGroupPicker(BuildContext context, IOUser usr, String group, List<Group> groupList) {
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
              groupList: groupList,
            )
          ]),
        ],
      );
    },
  );
}
