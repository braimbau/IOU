import 'package:deed/balance/balancing.dart';
import 'package:deed/cards/amount_card.dart';
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
  int state = 0; // 0:to do 1:ongoing 2:done
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
        if (state == 0)
          InkWell(
            customBorder: CircleBorder(),
            onTap: () async {
              setState(() {
                state = 1;
              });
              List<IOUser> selected = [];
              selected.add(IOUser(transaction.getId(), transaction.getName(),
                  transaction.getUrl()));
              String err = await runTransactionToUpdateBalances(
                  selected,
                  this.widget.group,
                  transaction.getBalance(),
                  this.widget.usr,
                  "Balancing");
              if (err == null) {
                newTransaction(
                    transaction.getBalance(),
                    transaction.getBalance(),
                    this.widget.usr,
                    selected,
                    "Balancing",
                    this.widget.group,
                    this.widget.usr.getId());
                setState(() {
                  state = 2;
                });
              } else {
                displayError("An error occured, please retry", context);
                setState(() {
                  state = 0;
                });
              }
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
        if (state == 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.pending,
              color: Colors.grey[500],
            ),
          ),
        if (state == 2)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.check_circle_outline_outlined,
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}
