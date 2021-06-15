import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'error_screen.dart';
import 'user.dart';
import 'iou_transaction.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class History extends StatelessWidget {
  final String id;

  History({@required this.id});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorScreen("something went wrong");
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
        return new HistoryUser(id: id);
      },
    );
  }
}

class HistoryUser extends StatelessWidget {
  final String id;

  HistoryUser({this.id});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .collection("transactions")
          .snapshots(),
      builder: (context, snapshot) {
        print("id = $id");
        if (snapshot.hasError) {
          return errorScreen("something went wrong");
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
                      transaction: transactionList[index],
                    );
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

  HistoryElement({this.transaction});

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
                  style: TextStyle(fontWeight: FontWeight.bold,
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
              if (isExpanded && this.widget.transaction.getOtherUsers() != "")
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Other users: ${this.widget.transaction.getOtherUsers()}",
                        style: TextStyle(color: Colors.black))),
            ])));
  }
}
