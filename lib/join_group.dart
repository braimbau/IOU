import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'error.dart';
import 'group_picker.dart';

class JoinGroup extends StatelessWidget {
  final IOUser usr;

  JoinGroup({this.usr});

  @override
  Widget build(BuildContext context) {
    String group;
    String groupName;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container(), flex: 1,),
          Text(
            "Join a group",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: 'Group code',
                          fillColor: Colors.white,
                          filled: true),
                      onChanged: (String str) {
                        group = str;
                      }),
                ),
                IconButton(
                    icon: Icon(
                      Icons.east,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (await groupExist(group)) addGroup(group, usr.getId());
                    }),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            "Create a new group",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: 'Group name',
                          fillColor: Colors.white,
                          filled: true),
                      onChanged: (String str) {
                        groupName = str;
                      }),
                ),
                IconButton(
                    icon: Icon(
                      Icons.east,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      String groupId = await createGroup(groupName);
                      displayMessage('Group $groupName is created', context);
                      addGroup(groupId, usr.getId());
                    }),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: GroupPicker(
              usr: usr,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> groupExist(String group) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("groups").doc(group);
  var doc = await document.get();
  return doc.exists;
}

Future<String> createGroup(String groupName) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("groups").doc();
  String group = document.id;
  await document.set({'name': groupName});
  return group;
}

Future<bool> addGroup(String group, String userId) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("users").doc(userId);
  var doc = await document.get();
  String groups = doc["groups"];
  List<String> groupList =
      (groups == null || groups == "") ? [] : groups.split(":");
  if (groupList.contains(group)) {
    return (false);
  } else {
    groupList.add(group);
    document.update({
      'groups': (groupList.length == 1) ? groupList[0] : groupList.join(":")
    });
    return true;
  }
}

Future<bool> setDefaultGroup(String group, String userId) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("users").doc(userId);
  var doc = await document.get();
  String groups = doc["groups"];
  List<String> groupList =
      (groups == null || groups == "") ? [] : groups.split(":");
  if (!groupList.contains(group)) {
    groupList.add(group);
    document.update({
      'groups': (groupList.length == 1) ? groupList[0] : groupList.join(":")
    });
  }
  document.update({'defaultGroup': group});
  return true;
}

Future<void> sendGroupCode(String code) async {
  if (await groupExist(code)) return;
}