import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/quick_pref.dart';
import 'package:deed/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickCard extends StatelessWidget {
  final IOUser usr;

  QuickCard({this.usr});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .doc("rfuvvQjatXbde1ZNL7O5")
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
          for (int i = 0; i < snapshot.data.docs.length; i++){
            quickPrefList.add(QuickPref(snapshot.data.doc["name"], snapshot.data.doc["users"], snapshot.data.doc["amount"], snapshot.data.doc["emoji"]));
          }


        });
  }
}
