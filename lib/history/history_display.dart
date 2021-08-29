import 'package:deed/classes/iou_transaction.dart';
import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'history_element.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HistoryDisplay extends StatefulWidget {
  final List<IOUser> userList;
  final List<IouTransaction> transactionList;
  final String group;
  final IOUser usr;

  HistoryDisplay({this.userList, this.transactionList, this.group, this.usr});

  @override
  _HistoryDisplayState createState() => _HistoryDisplayState();
}

class _HistoryDisplayState extends State<HistoryDisplay> {
  bool inc = false;
  bool date = true;

  @override
  Widget build(BuildContext context) {
    List<IOUser> userList = this.widget.userList;
    List<IouTransaction> transactionList = this.widget.transactionList;
    String group = this.widget.group;
    IOUser usr = this.widget.usr;

    transactionList.sort((IouTransaction a, IouTransaction b){
      if (!inc) {
        IouTransaction t = a;
        a = b;
        b = t;
      }
      if (date)
        return a.getTimestamp() - b.getTimestamp();
      return a.getBalanceEvo() - b.getBalanceEvo();
    });

    AppLocalizations t = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    InkWell(
                      child:
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(inc ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.blue,),
                          ),
                      onTap: () {
                        setState(() {
                          inc = !inc;
                        });
                      },
                    ),
                    InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 20,
                            child: date
                                ? Icon(Icons.access_time, color: Colors.blue)
                                : Text(
                                    "€",
                                    style: TextStyle(fontSize: 25, color: Colors.blue),
                                  ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            date = !date;
                          });
                        })
                  ],
                ),
                Expanded(
                  child: FittedBox(
                    child: Text(t.history,
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 40),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
          Divider(thickness: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: transactionList.length,
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
                  userList: userList,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
