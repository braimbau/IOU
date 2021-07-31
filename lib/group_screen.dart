import 'package:cloud_firestore/cloud_firestore.dart';
import 'join_group.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';

import 'error_screen.dart';
import 'loading.dart';
import 'main_page.dart';

class GroupScreen extends StatelessWidget {
  final IOUser usr;
  final String groupInvite;

  GroupScreen({this.usr, this.groupInvite});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getDefaultGroups(usr.getId()),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          if (snapshot.data == "" || snapshot.data == null || snapshot.hasError)
            return JoinGroup(usr: usr, groupInvite: groupInvite);

          if (snapshot.data != null && snapshot.data != ""){
            checkGroup(usr, snapshot.data);
            return (mainPage(context, usr, snapshot.data));
          }

          return Container();
        });
  }

}

Future<String> getDefaultGroups(String userId) async {
  final DocumentReference document = FirebaseFirestore.instance.collection(
      "users").doc(userId);
  var doc = await document.get();
  return doc["defaultGroup"];
}

Future<bool> isInGroup(String id, String group) async {
  final DocumentReference document = FirebaseFirestore.instance.collection(
      "users").doc(id).collection("groups").doc(group);
  var doc = await document.get();
  return doc.exists;
}

Future<void> checkGroup(IOUser usr, String group) async
{
  if (!await isInGroup(usr.getId(), group)) {
    var docRef = FirebaseFirestore.instance.collection('users')
        .doc(usr.getId())
        .collection("groups")
        .doc(group);
    docRef.set({'balance': 0});
    print("creating balance for this user");
    docRef =
        FirebaseFirestore.instance.collection('groups').doc(group).collection(
            "users").doc(usr.getId());
    docRef.set(
        {'name': usr.getName(), 'url': usr.getUrl(), 'id': usr.getId()});
  }
}