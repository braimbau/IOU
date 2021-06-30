import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/amount_card.dart';
import 'package:deed/pref_picker.dart';
import 'package:deed/quick_pref.dart';
import 'package:deed/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickCard extends StatelessWidget {
  final IOUser usr;
  final String group;

  QuickCard({this.usr, this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .doc(group)
            .collection("quickadds")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          List<QuickPref> quickPrefList = List<QuickPref>.empty(growable: true);
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            quickPrefList.add(QuickPref(
                snapshot.data.docs[i]["name"],
                snapshot.data.docs[i]["users"],
                snapshot.data.docs[i]["amount"],
                snapshot.data.docs[i]["emoji"],
                snapshot.data.docs[i].id));
          }
          return new Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // if you need this
              side: BorderSide(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            color: Colors.black,
            semanticContainer: true,
            elevation: 5,
            child: Column(
              children: [
                Padding(
                    child: Text("Quick Adds :",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    padding: EdgeInsets.all(8)),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: quickPrefList.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      return (index != quickPrefList.length)
                          ? TextButton(
                              child: Text(
                                quickPrefList[index].getEmoji(),
                                style: TextStyle(fontSize: 50),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _buildPopupDialog(context, usr,
                                          quickPrefList[index], group),
                                );
                              },
                              onLongPress: () {
                                _confirmQuickDelete(
                                    context, quickPrefList[index], group);
                              },
                            )
                          : Padding(
                              child: IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    size: 30,
                                    color: Colors.blue,
                                  ),
                                  splashRadius: 25,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _buildPrefPicker(),
                                    );
                                  }),
                              padding: EdgeInsets.only(top: 15));
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}

Future<void> _confirmQuickDelete(
    BuildContext context, QuickPref pref, String group) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete ${pref.getName()}'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Are you sure you want to delete this quick add ?'),
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
            child: Text('Delete'),
            onPressed: () {
              removeQuickPref(group, pref.getId());
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> removeQuickPref(String groupId, String id) async {
  CollectionReference ref = FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection("quickadds");
  ref.doc(id).delete();
}

Widget _buildPopupDialog(
    BuildContext context, IOUser usr, QuickPref pref, String group) {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Wrap(children: <Widget>[
            AmountCard(
                currentUserId: usr.getId(),
                isPreFilled: true,
                pref: pref,
                group: group)
          ])));
}

Widget _buildPrefPicker() {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Wrap(children: <Widget>[PrefPicker()])));
}
