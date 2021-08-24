import 'dart:ui';

import 'package:deed/balance/balancing.dart';
import 'package:deed/cards/amount_card.dart';
import 'package:deed/classes/quick_pref.dart';
import 'package:deed/classes/user.dart';
import 'package:deed/utils/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BalancingTransaction extends StatefulWidget {
  final UserBalance transaction;
  final String group;
  final IOUser usr;

  BalancingTransaction({this.transaction, this.group, this.usr});

  @override
  _BalancingTransactionState createState() => _BalancingTransactionState();
}

class _BalancingTransactionState extends State<BalancingTransaction> {
  @override
  Widget build(BuildContext context) {
    UserBalance transaction = this.widget.transaction;
    double amount = transaction.getBalance().abs() / 100;
    String dAmount = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).primaryColor,
          child: CircleAvatar(
              radius: 18, backgroundImage: NetworkImage(transaction.getUrl())),
        ),
        Column(
          children: [
            Text(
              (transaction.getBalance() > 0)
                  ? "Refund $dAmount€ "
                  : "Get a $dAmount€ refund",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              ((transaction.getBalance() > 0) ? "to" : "from") +
                  " ${transaction.getName()}",
              style: Theme.of(context).textTheme.bodyText1,
            )
          ],
        ),
          InkWell(
            customBorder: CircleBorder(),
            onTap: () {
              QuickPref pref = QuickPref("Balancing", this.widget.usr.getId(), -transaction.getBalance(), null, transaction.getId());
              showPopUpDialog(context, transaction.getId(), pref, this.widget.group);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.arrow_circle_up_outlined,
                    color: Colors.green,
                  )),
            ),
          ),
      ],
    );
  }
}

void showPopUpDialog(BuildContext context, String usrId, QuickPref pref, String group) {
  showDialog(
    context: context,
    builder: (BuildContext context) =>
        _buildPopupDialog(context, usrId,
            pref, group),
  );
}

Widget _buildPopupDialog(
    BuildContext context, String usrId, QuickPref pref, String group) {
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
                currentUserId: usrId,
                isPreFilled: true,
                pref: pref,
                group: group)
          ])));
}