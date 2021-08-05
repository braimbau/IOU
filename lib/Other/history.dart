import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/loading.dart';
import '../classes/quick_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../cards/amount_card.dart';
import '../utils/error_screen.dart';
import '../classes/user.dart';
import '../classes/iou_transaction.dart';
import 'package:intl/intl.dart';

class History extends StatelessWidget {
  final IOUser usr;
  final String group;

  History({@required this.usr, this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorScreen("something went wrong in history");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }
        if (snapshot.data.docs.length == 0)
          return errorScreen("No users to display");

        List<IOUser> userList = List<IOUser>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          userList.add(IOUser(snapshot.data.docs[i]["id"],
              snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }
        return new HistoryUser(usr: usr, group: group);
      },
    );
  }
}

class HistoryUser extends StatelessWidget {
  final IOUser usr;
  final String group;

  HistoryUser({this.usr, this.group});

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
              snapshot.data.docs[i]["otherUsers"],
              snapshot.data.docs[i]["payer"],
              snapshot.data.docs[i]["label"]));
        }

        return new Scaffold(
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(width: 72.0, height: 0.0),
                  Text("History",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 50)),
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
              Divider(color: Colors.grey[800], thickness: 1),
              Expanded(
                //height: 500,

                /*     child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return HistoryElement(
                    transaction: transactionList[index],
                  );
                },
              )*/

                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data.docs.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.grey,
                      endIndent: 10,
                      indent: 10,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return HistoryElement(
                        transaction: transactionList[index], usr: usr, group: group);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class HistoryElement extends StatefulWidget {
  final IouTransaction transaction;
  final IOUser usr;
  final String group;

  HistoryElement({this.transaction, this.usr, this.group});

  @override
  _HistoryElementState createState() => _HistoryElementState();
}

class _HistoryElementState extends State<HistoryElement> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var date = DateTime.fromMillisecondsSinceEpoch(
        this.widget.transaction.getTimestamp());
    var formattedDate = DateFormat.yMMMd().add_Hm().format(date); // Apr 8, 2020
    String evo = (((this.widget.transaction.getBalanceEvo() > 0) ? "+" : "") +
        (this.widget.transaction.getBalanceEvo() / 100).toString());
    double displayedAmount = this.widget.transaction.getDisplayedAmount() / 100;

    return InkWell(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(children: [
              Text(this.widget.transaction.getLabel(),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              Row(children: [
                Text(formattedDate,
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic)),
                Expanded(child: Container()),
                Text(
                  evo,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (this.widget.transaction.getBalanceEvo() >= 0)
                          ? Colors.green
                          : Colors.red),
                ),
              ]),
              if (isExpanded)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Payer: ${this.widget.transaction.getPayer()}",
                        style: TextStyle(color: Colors.black))),
              if (isExpanded)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Total amount: $displayedAmount€",
                        style: TextStyle(color: Colors.black))),
              if (isExpanded &&
                  this.widget.transaction.getUsers() != "" &&
                  2 == 3)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Other users: ${this.widget.transaction.getUsers()}",
                        style: TextStyle(color: Colors.black))),
              if (isExpanded)
                IconButton(
                  icon: Icon(Icons.replay, color: Colors.blue),
                  onPressed: () async {
                    Navigator.pop(context);
                    QuickPref pref = QuickPref(
                        this.widget.transaction.getLabel(),
                        this.widget.transaction.getUsers(),
                        this.widget.transaction.getDisplayedAmount(),
                        null,
                        null);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildPopupDialog(context, this.widget.usr, pref, this.widget.group),
                    );
                  },
                )
            ])));
  }
}

Widget _buildPopupDialog(BuildContext context, IOUser usr, QuickPref pref, String group) {
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
                currentUserId: usr.getId(), pref: pref, isPreFilled: true, group: group,)
          ])));
}
