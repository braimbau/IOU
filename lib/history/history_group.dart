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
import 'history_group_display.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HistoryGroup extends StatelessWidget {
  final String group;
  final IOUser usr;

  HistoryGroup({this.group, this.usr});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("groups")
          .doc(group)
          .collection("transactions")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorScreen(t.err1);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (snapshot.data.docs.length == 0) {
          return errorScreen(t.noTransactionsGroup);
        }

        List<IouTransaction> transactionList =
        List<IouTransaction>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          transactionList.add(IouTransaction(
              snapshot.data.docs[i]["time"],
              snapshot.data.docs[i]["time"],
              0,
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
              return HistoryGroupDisplay(userList: snap.data, transactionList: transactionList, group: group, usr: usr,);
            });
      },
    );
  }
}
