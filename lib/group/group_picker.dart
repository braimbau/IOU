import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/classes/group.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../Utils.dart';
import '../Routes/main_page.dart';
import '../classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/error_screen.dart';
import '../utils/loading.dart';

class GroupPicker extends StatelessWidget {
  final IOUser usr;
  final String excludeGroup;
  final List<Group> groupList;

  GroupPicker({this.usr, this.excludeGroup, this.groupList});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(usr.getId())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorScreen('Something went wrong with groups');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          String groups = snapshot.data["groups"];

          List<String> stringGroupList =
              (groups == "" || groups == null) ? [] : groups.split(':');

          if (excludeGroup != null) stringGroupList.remove(excludeGroup);

          return LimitedBox(
            maxHeight: 150,
            child: ListView.separated(
              shrinkWrap: true,
                itemCount: stringGroupList.length,
                separatorBuilder: (BuildContext contex, int index) {
                  return Container(
                    height: 5,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  String group = stringGroupList[index];
                  return Row(
                    children: [
                      if (groupList.contains(Group(group, null)))
                        Text(
                          groupList.firstWhere((element) => element.getId() == group).getName(),
                          style: TextStyle(),
                        )
                  else
                      FutureBuilder<String>(
                          future: getGroupNameById(group),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> groupName) {
                            if (groupName.hasData)
                              return Text(
                                groupName.data,
                                style: TextStyle(),
                              );
                            else
                              return Text(
                                "...",
                                style: TextStyle(),
                              );
                          }),
                      InkWell(
                          onTap: () async {
                            goMainPageWithGroup(context, usr, group);
                          },
                          radius: 5,
                          customBorder: CircleBorder(),
                          child: Icon(Icons.east_rounded, color: Theme.of(context).primaryColor))
                    ],
                  );
                }),
          );
        });
  }
}

Future<void> goMainPageWithGroup(
    BuildContext context, IOUser usr, String group) async {
  await checkGroup(usr, group);
  await updateUserInfosFromGroup(usr, group);
  Navigator.of(context).pop();
  Navigator.pushReplacementNamed(context, '/mainPage',
      arguments: MainPageArgs(usr: usr, group: group));
}

