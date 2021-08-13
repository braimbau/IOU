import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/Utils.dart';
import '../utils/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/error_screen.dart';
import '../classes/user.dart';
import '../classes/iou_transaction.dart';

import 'history_element.dart';

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
              return Scaffold(
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(width: 72.0, height: 0.0),
                        Text("History",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 50)),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: IconButton(
                            icon: Icon(Icons.close, size: 40),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    ),
                    Divider(thickness: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data.docs.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            color: Colors.grey[500],
                            endIndent: 10,
                            indent: 10,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return HistoryElement(
                            transaction: transactionList[index],
                            usr: usr,
                            group: group,
                            userList: snap.data,
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            });
      },
    );
  }
}
