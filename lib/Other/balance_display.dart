import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../classes/user.dart';

class BalanceCard extends StatelessWidget {
  final IOUser usr;
  final String group;

  BalanceCard({this.usr, this.group});

  @override
  Widget build(BuildContext context) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(usr.getId())
              .collection("groups")
              .doc(group)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            double balance;
            try {balance = snapshot.data["balance"] / 100;
            }
            catch (_) {
            return Container();
            }
            String dbalance = ""; //(balance > 0) ? "+" : "";
            dbalance += balance
                .toStringAsFixed(balance.truncateToDouble() == balance ? 0 : 2);

            return FittedBox(
              child: Text("$dbalance€",
                  style: TextStyle(
                      color: (balance >= 0) ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 5000)),
            );
          });
    }
}
