import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'user.dart';
import 'user.dart';

class BalanceCard extends StatelessWidget {
  final IOUser usr;

  BalanceCard({this.usr});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(usr.getId())
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }


          int scale = 100;
          double balance = snapshot.data["balance"] / 100;
          String dbalance = (balance > 0) ? "+" : "";
          dbalance += balance.toStringAsFixed(balance.truncateToDouble() == balance ? 0 : 2);


          return new Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // if you need this
                side: BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              color: (balance > 0) ? Colors.red : Colors.green,
              semanticContainer: true,
              elevation: 5,
              child: Column(
                children: [
                  Text("$dbalance€", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 50)),
                ],
              ));
        });
  }
}
