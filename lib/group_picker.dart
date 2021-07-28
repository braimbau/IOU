import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user.dart';

import 'error_screen.dart';
import 'join_group.dart';
import 'loading.dart';

class GroupPicker extends StatelessWidget {
  final IOUser usr;
  final String excludeGroup;

  GroupPicker({this.usr, this.excludeGroup});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(usr.getId())
            .snapshots(),
        builder: (context, snapshot) {
          print("jme build");
          if (snapshot.hasError) {
            return errorScreen('Something went wrong with groups');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          String groups = snapshot.data["groups"];

          List<String> groupList =
              (groups == "" || groups == null) ? [] : groups.split(':');

          if(excludeGroup != null)
            groupList.remove(excludeGroup);


          return ListView.separated(
              itemCount: groupList.length,
              separatorBuilder: (BuildContext contex, int index) {
                return Container(height: 5,);
              },
              itemBuilder: (BuildContext context, int index) {
                String group = groupList[index];
                return Row(
                  children: [
                    FutureBuilder<String>(
                        future: getGroupNameById(group),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> groupName) {
                          if (groupName.hasData)
                            return Text(groupName.data, style: TextStyle(color: Colors.white),);
                          else
                            return Text("...", style: TextStyle(color: Colors.white),);
                        }),
                    InkWell(
                        onTap: () async {
                          await goMainPageWithGroup(context, usr, group);
                        },
                        radius: 5,
                        customBorder: CircleBorder(),
                        child: Icon(Icons.east_rounded, color: Colors.white,))
                  ],
                );
              });
        });
  }
}

class GroupPickerCard extends StatefulWidget {
  final IOUser usr;
  final String excludeGroup;

  GroupPickerCard({this.usr, this.excludeGroup});

  @override
  _GroupPickerCardState createState() => _GroupPickerCardState();
}

class _GroupPickerCardState extends State<GroupPickerCard> {
  IOUser usr;

  @override
  Widget build(BuildContext context) {
    IOUser usr = this.widget.usr;

    return Card(
        color: Colors.grey,
        child: SizedBox(
          width: 150,
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: GroupPicker(
                    usr: usr,
                    excludeGroup: this.widget.excludeGroup,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    goJoinGroup(context, usr);
                  },
                  child: Text('Join/Create',),
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(), primary: Colors.black),
                ),
              ],
            ),
          ),
        ));
  }
}

Future<String> getGroupNameById(String id) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("groups").doc(id);
  var doc = await document.get();
  return doc["name"];
}

Future<void> goMainPageWithGroup(
    BuildContext context, IOUser usr, String group) async {
  await checkGroup(usr, group);
  await updateUserInfosFromGroup(usr, group);
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            mainPage(context, usr, group),
        transitionDuration: Duration(seconds: 0)),
  );
}

Future<void> goJoinGroup(
    BuildContext context, IOUser usr) async {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            JoinGroup(usr: usr,),
        transitionDuration: Duration(seconds: 0)),
  );
}

Future<bool> isInGroup(String id, String group) async {
  final DocumentReference document = FirebaseFirestore.instance
      .collection("users")
      .doc(id)
      .collection("groups")
      .doc(group);
  var doc = await document.get();
  return doc.exists;
}

Future<void> updateUserInfosFromGroup(IOUser usr, String group) async {
  final DocumentReference document = FirebaseFirestore.instance
      .collection("groups")
      .doc(group)
      .collection("users")
      .doc(usr.getId());
  var doc = await document.get();
  usr.setUrl(doc['url']);
  usr.setName(doc['name']);
  print(doc['url']);
  return;
}

Future<void> checkGroup(IOUser usr, String group) async {
  if (!await isInGroup(usr.getId(), group)) {
    var docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(usr.getId())
        .collection("groups")
        .doc(group);
    docRef.set({'balance': 0});
    print("creating balance for this user");
    docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(group)
        .collection("users")
        .doc(usr.getId());
    docRef.set({'name': usr.getName(), 'url': usr.getUrl(), 'id': usr.getId()});
  }
}
