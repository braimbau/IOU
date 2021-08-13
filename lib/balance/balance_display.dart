import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../classes/user.dart';
import 'balancing.dart';

class BalanceCard extends StatelessWidget {
  final IOUser usr;
  final String group;

  BalanceCard({this.usr, this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .doc(group)
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
          double balance;
          try {
            balance = snapshot.data["balance"] / 100;
          } catch (_) {
            return Container();
          }
          String dbalance = "";
          dbalance += balance
              .toStringAsFixed(balance.truncateToDouble() == balance ? 0 : 2);

          return Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Flexible(
                  child: FittedBox(
                    child: Text("$dbalance€",
                        style: TextStyle(
                            color: (balance >= 0) ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 5000)),
                  ),
                ),
                Visibility(
                  visible: snapshot.data["balance"] != 0,
                  child: InkWell(
                    onTap: () {
                      showBalancingOptions(context, usr, group);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz),
                          Text("Balancing options")
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}

void showBalancingOptions(BuildContext context, IOUser usr, String group) {
  showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Balancing(args: BalancingArgs(usr: usr, groupId: group),
                )));
      });
}

