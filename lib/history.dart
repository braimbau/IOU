import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'iou_transaction.dart';
import 'package:intl/intl.dart';

class History extends StatelessWidget {
  final String id;

  History({@required this.id});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        if (snapshot.data.docs.length == 0) return Text("No users to display");

        List<User> userList = List<User>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          userList.add(User(snapshot.data.docs[i]["id"],
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
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        if (snapshot.data.docs.length == 0) return Text("No transactions");

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

        return new Column(
          children: [
            Text("History",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Divider(color: Colors.white),
            SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return HistoryElement(
                      transaction: transactionList[index],
                    );
                  },
                ))
          ],
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
    String evo = (((this.widget.transaction.getBalanceEvo() > 0) ? "+" : "") + (this.widget.transaction.getBalanceEvo() / 100).toString());
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
          Row(children: [
            Text("$formattedDate : ", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            Text(this.widget.transaction.getLabel(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(" : ", style: TextStyle(color: Colors.grey)),
            Text(evo,
                style: TextStyle(
                    color: (this.widget.transaction.getBalanceEvo() >= 0)
                        ? Colors.green
                        : Colors.red)),
          ]),
          if (isExpanded) Align(alignment: Alignment.centerLeft,child: Text("Payer: ${this.widget.transaction.getPayer()}", style: TextStyle(color: Colors.white))),
          if (isExpanded) Align(alignment: Alignment.centerLeft,child: Text("Total amount: $displayedAmount€", style: TextStyle(color: Colors.white))),

          if (isExpanded) Divider(color: Colors.white),
        ])
    ));
  }
}
