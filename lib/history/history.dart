import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/Utils.dart';
import 'package:deed/history/history_display.dart';
import '../utils/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/error_screen.dart';
import '../classes/user.dart';
import '../classes/iou_transaction.dart';

class History extends StatelessWidget {
  final IOUser usr;
  final String group;

  History({this.usr, this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(usr.getId())
          .collection("groups")
          .doc(group)
          .collection("transactions")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorScreen("something went wrong in history 2");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (snapshot.data.docs.length == 0) {
          return errorScreen("No transactions for this user");
        }

        List<IouTransaction> transactionList =
            List<IouTransaction>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          transactionList.add(IouTransaction(
              snapshot.data.docs[i]["transactionID"],
              snapshot.data.docs[i]["transactionID"],
              snapshot.data.docs[i]["balanceEvo"],
              snapshot.data.docs[i]["displayedAmount"],
              snapshot.data.docs[i]["selectedUsers"],
              snapshot.data.docs[i]["payer"],
              snapshot.data.docs[i]["label"],
              snapshot.data.docs[i]['actualAmount']));
        }
        transactionList.sort((IouTransaction a, IouTransaction b) {return b.getTimestamp() - a.getTimestamp();});
        return FutureBuilder(
            future: getGroupUserList(group),
            builder: (BuildContext context, AsyncSnapshot<List<IOUser>> snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return Loading();
              return HistoryDisplay(userList: snap.data, transactionList: transactionList, group: group, usr: usr,);
            });
      },
    );
  }
}
