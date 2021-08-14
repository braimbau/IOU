import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/utils/image_import.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'classes/group.dart';
import 'classes/user.dart';

Future<String> getGroupNameById(String id) async {
  final DocumentReference document =
  FirebaseFirestore.instance.collection("groups").doc(id);
  var doc = await document.get();
  return doc["name"];
}

Future<bool> updateUserInfosFromGroup(IOUser usr, String group) async {
  final DocumentReference document = FirebaseFirestore.instance
      .collection("groups")
      .doc(group)
      .collection("users")
      .doc(usr.getId());
  var doc = await document.get();
  usr.setUrl(doc['url']);
  usr.setName(doc['name']);
  return true;
}

Future<int> getBalance(String usrId, String group) async {
  final DocumentReference document = FirebaseFirestore.instance
      .collection("groups")
      .doc(group)
      .collection("users")
      .doc(usrId);
  var doc = await document.get();
  return doc["balance"];
}

Future<int> getBalanceT(String usrId, String group, Transaction tr) async {
  final DocumentReference document = FirebaseFirestore.instance
      .collection("groups")
      .doc(group)
      .collection("users")
      .doc(usrId);
  var doc = await tr.get(document);
  return doc["balance"];
}

Future<void> checkGroup(IOUser usr, String group) async {
  if (!await userIsInGroup(group,usr.getId())) {
    var docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(group)
        .collection("users")
        .doc(usr.getId());
    docRef.set({'balance': 0, 'name': usr.getName(), 'url': usr.getUrl(), 'id': usr.getId()});
    print("creating balance for this user");
  }
}

Future<String> getGroupDynamicLink(String group, String groupName) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://altua.page.link',
    link: Uri.parse('https://iouapp.carrd.co/?group=$group'),
    androidParameters: AndroidParameters(
      packageName: 'com.altua.iou',
    ),
    iosParameters: IosParameters(
      bundleId: 'com.altua.iouapp',
      minimumVersion: '1.0.0',
      appStoreId: '1575234438',
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: "IOU - Invitation to $groupName",
      imageUrl: Uri.parse("https://firebasestorage.googleapis.com/v0/b/iou-71bca.appspot.com/o/InvitationPreview.png?alt=media&token=6ed44008-7fcd-4a4e-9bd0-18462da18bda"),

    )
  );

  final ShortDynamicLink short = await parameters.buildShortLink();
  final Uri dynamicUrl = short.shortUrl;
  return dynamicUrl.toString();
}

Future<String> getDefaultGroup(String userId) async {
  final DocumentReference document = FirebaseFirestore.instance.collection(
      "users").doc(userId);
  var doc = await document.get();
  return doc["defaultGroup"];
}

Future<String> getDefaultGroupT(String userId, Transaction tr) async {
  final DocumentReference document = FirebaseFirestore.instance.collection(
      "users").doc(userId);
  var doc = await tr.get(document);
  return doc["defaultGroup"];
}

Future<List<String>> getGroups(String userId) async {
  final DocumentReference document = FirebaseFirestore.instance.collection(
      "users").doc(userId);
  var doc = await document.get();
  String groups = doc["groups"];
  return groups.split(":");
}

Future<void> setDefaultGroup(String usrId, String group) async {
  final DocumentReference document = FirebaseFirestore.instance.collection(
      "users").doc(usrId);
  await document.update({'defaultGroup': group});
}

Future<void> setDefaultGroupT(String usrId, String group, Transaction tr) async {
  final DocumentReference document = FirebaseFirestore.instance.collection(
      "users").doc(usrId);
  tr.update(document, {'defaultGroup': group});
}

Future<bool> toggleDefaultGroup(String usrId, String group) async {
  String def = await getDefaultGroup(usrId);
  if (def != group) {
    setDefaultGroup(usrId, group);
    return true;
  }
  setDefaultGroup(usrId, null);
  return false;
}

Future<bool> userIsInGroup(String group, String usrId) async {
  final DocumentReference document = FirebaseFirestore.instance
      .collection("groups")
      .doc(group)
      .collection("users")
      .doc(usrId);
  var doc = await document.get();
  return doc.exists;
}

Future<bool> userIsInGroupT(String group, String usrId, Transaction tr) async {
  final DocumentReference document = FirebaseFirestore.instance
      .collection("groups")
      .doc(group)
      .collection("users")
      .doc(usrId);
  var doc = await tr.get(document);
  return doc.exists;
}

Future<void> createUser(String name, String url, String id) async
{
  var  docRef = FirebaseFirestore.instance.collection('users').doc(id);
  docRef.set({'name': name, 'url' : url, 'id': id, 'groups': "", 'defaultGroup': "", 'creationDate': DateTime.now().millisecondsSinceEpoch});
}

Future<bool> userExist(String id) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("users").doc(id);
  var doc = await document.get();
  return doc.exists;
}

Future<bool> groupExist(String id) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("groups").doc(id);
  var doc = await document.get();
  return doc.exists;
}

Future<bool> groupExistT(String id, Transaction tr) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("groups").doc(id);
  var doc = await tr.get(document);
  return doc.exists;
}

Future<IOUser> getUserById (String id) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("users").doc(id);
  var doc = await document.get();
  IOUser usr = IOUser(id, doc["name"], doc["url"]);
  usr.setGroups(doc["groups"]);
  return usr;
}

Future<void> changePhotoUrl(String id, String url, String group) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('groups').doc(group).collection('users');
  ref.doc(id).update({"url": url});
}

Future<String> leaveGroup(String usrId, String group) async {
  final db = FirebaseFirestore.instance;
  return await db.runTransaction((Transaction tr) async {

    if (!await groupExistT(group, tr))
      return("You can't leave a group that doesn't exist anymore");
    if (!await userIsInGroupT(group, usrId, tr)) {
      return ("This user already left the group");
    }
    if (await getBalanceT(usrId, group, tr) != 0)
      return ("You need to have a null balance to leave a group");

    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    var doc = await tr.get(ref.doc(usrId));

    if (await getDefaultGroupT(usrId, tr) == group)
      setDefaultGroupT(usrId, null, tr);

    String groups = doc["groups"];
    List<String> groupList = (groups == "" || groups == null) ? [] : groups.split(':');
    groupList.remove(group);
    groups = groupList.join(":");
    ref.doc(usrId).update({"groups": groups});

    ref = FirebaseFirestore.instance.collection('groups').doc(group).collection('users');
    tr.delete(ref.doc(usrId));

    ref = FirebaseFirestore.instance.collection('users').doc(usrId).collection('groups');
    tr.delete(ref.doc(group));

    ref.doc(group).collection('transactions').snapshots().forEach((element) {
      for (QueryDocumentSnapshot snapshot in element.docs) {
        snapshot.reference.delete();
      }
    });

    return null;


  }).then((value) {
    if (value == null) {
      removeImageOfFirebase(usrId + group);
      deleteGroupIfEmpty(group);
    }
    return value;
  }).catchError((error) {
    print("Transaction error : $error");
    return "An error occured, please retry";
  });
}

Future<bool> groupIsEmpty(String group) async {
  var ref = await FirebaseFirestore.instance.collection("groups").doc(group).collection("users").get();
  if (ref.docs.length == 0)
    return true;
  return false;
}

Future<void> deleteGroup(String group) async {
  DocumentReference ref = FirebaseFirestore.instance.collection("groups").doc(group);
  ref.collection('transactions').snapshots().forEach((element) {
    for (QueryDocumentSnapshot snapshot in element.docs) {
      snapshot.reference.delete();
    }
  });
  ref.delete();
}

Future<void> deleteGroupIfEmpty(String groupId) async {
  if (await groupIsEmpty(groupId))
    await deleteGroup(groupId);
}

Future<List<Group>> getGroupsById(List<String> stringList) async {
  List<Group> groupList = [];

  var snapshot = await FirebaseFirestore.instance.collection('groups').get();

  stringList.forEach((groupId) {
    var doc = snapshot.docs.firstWhere((element) => (element.id == groupId));
    groupList.add(Group(doc.id, doc.data()['name']));

  });
  return groupList;
}

Future<List<Group>> getGroupsByUserId(String usrId) async {
  List<String> stringList = await getGroups(usrId);
  List<Group> groupList = [];

  var snapshot = await FirebaseFirestore.instance.collection('groups').get();

  stringList.forEach((groupId) {
    var doc = snapshot.docs.firstWhere((element) => (element.id == groupId));
    groupList.add(Group(doc.id, doc.data()['name']));

  });
  return groupList;
}

Future<Map<String, String>> getUserGroupsMap(String usrId) async {
  List<String> groupList = await getGroups(usrId);
  Map<String, String> map = Map<String, String>();
  for (String groupId in groupList) {
  map[groupId] = await getGroupNameById(groupId);
  }
  return map;
}

Future<bool> isVersionUpToDate() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String localVersion = packageInfo.version;
  DocumentReference ref = FirebaseFirestore.instance.collection('infos').doc('app');
  DocumentSnapshot doc = await ref.get();
  String dbVersion = doc['version'];
  var dbTab = dbVersion.split('.').map(int.parse).toList();
  var localTab = localVersion.split('.').map(int.parse).toList();
  print(dbTab);
  print(localTab);
  if (dbTab[0] > localTab[0]) {
    print("Versions not matching : DB: $dbVersion Local: $localVersion");
    return false;
  }
  if (dbTab[0] == localTab[0] && dbTab[1] > localTab[1]) {
    print("Versions not matching : DB: $dbVersion Local: $localVersion");
    return false;
  }
  return true;
}

Future<List<IOUser>> getGroupUserList(String group) async {
  List<IOUser> userList = [];
  CollectionReference ref = FirebaseFirestore.instance.collection("groups").doc(group).collection('users');
  QuerySnapshot snap = await ref.get();
  for (int i = 0; i < snap.docs.length; i++) {
    userList.add(IOUser(snap.docs[i]["id"],
        snap.docs[i]["name"], snap.docs[i]["url"]));
  }
  return userList;
}

Future<bool> addGroupT(String group, String userId, Transaction tr) async {
  final DocumentReference document =
  FirebaseFirestore.instance.collection("users").doc(userId);
  var doc = await tr.get(document);
  String groups = doc["groups"];
  List<String> groupList =
  (groups == null || groups == "") ? [] : groups.split(":");
  if (groupList.contains(group)) {
    return (false);
  } else {
    groupList.add(group);
    tr.update(document, {
      'groups': (groupList.length == 1) ? groupList[0] : groupList.join(":")
    });
    return true;
  }
}

Future<String> joinGroupT(String usrId, String groupId) async {
  final db = FirebaseFirestore.instance;
  return await db.runTransaction((Transaction tr) async {
    if (! await groupExistT(groupId, tr))
      return ("This group doesn't exist");
    if (await userIsInGroupT(groupId, usrId, tr))
      return ("User is already in this group");
    if (await addGroupT(groupId, usrId, tr))
    checkGroup(await getUserById(usrId), groupId);
    return null;
  }).then((value) {
    return value;
  }).catchError((error) {
    print("Transaction error : $error");
    return "An error occured, please retry";
  });
}