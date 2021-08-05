import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'Utils.dart';
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
        color: Colors.grey,
        child: SizedBox(
          width: 175,
          height: 210,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      groupMap[group],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                FavGroup(usrId: usr.getId(), group: group),
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
                    //go to join Page
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Join/Create',
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(), primary: Colors.black),
                ),
              ],
            ),
          ),
        ));
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
