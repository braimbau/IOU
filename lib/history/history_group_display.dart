import 'package:deed/classes/iou_transaction.dart';
import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'history_group_element.dart';

class HistoryGroupDisplay extends StatefulWidget {
  final List<IOUser> userList;
  final List<IouTransaction> transactionList;
  final String group;
  final IOUser usr;

  HistoryGroupDisplay({this.userList, this.transactionList, this.group, this.usr});

  @override
  _HistoryGroupDisplayState createState() => _HistoryGroupDisplayState();
}

class _HistoryGroupDisplayState extends State<HistoryGroupDisplay> {
  bool inc = false;
  bool date = true;

  @override
  Widget build(BuildContext context) {
    List<IOUser> userList = this.widget.userList;
    List<IouTransaction> transactionList = this.widget.transactionList;
    String group = this.widget.group;

    transactionList.sort((IouTransaction a, IouTransaction b){
      if (!inc) {
        IouTransaction t = a;
        a = b;
        b = t;
      }
      if (date)
        return a.getTimestamp() - b.getTimestamp();
      return a.getDisplayedAmount() - b.getDisplayedAmount();
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
                Text(t.groupHistory,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
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
                return HistoryGroupElement(
                  transaction: transactionList[index],
                  group: group,
                  usr: this.widget.usr,
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
