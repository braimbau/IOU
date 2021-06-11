import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/user_display.dart';
import 'amount_card.dart';
import 'balance_card.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'history.dart';
import 'user.dart';

Widget mainPage(BuildContext context, IOUser usr) {

  AmountInfo amountInfo = AmountInfo();
  return GestureDetector(
    onTap: () {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    },
    child: Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 30.0,
                  width: 30.0,
                  child: new Image.asset('asset/image/logo.png')),
            Text('IOU'),
            ]),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ListView(
          children: <Widget> [
            UserDisplay(usr: usr),
            BalanceCard(usr: usr),
            AmountCard(),
            History(id: usr.getId()),
          ],
        ),
      ),
    ),
  );
}

class AmountInfo {
  double total;
  var controller;


  AmountInfo() {
    this.total = 0;
    this.controller = TextEditingController();
  }

  changeTotal(double price) {
    this.total = price;
  }
}

class BalanceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("stream2");
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        if (snapshot.data.docs.length == 0)
          return Text("No users to display");

        return new ListView.builder(
          itemCount: snapshot.data.docs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index)
          {
            String name = snapshot.data.docs[index]['name'];
            int balance = snapshot.data.docs[index]['balance'];
            return Text("$name : $balance centimes", style: TextStyle(color : (balance == 0) ? Colors.white : (balance > 0) ? Colors.green : Colors.red));
          },
        );
      },
    );
  }
}
