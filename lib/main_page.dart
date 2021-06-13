import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/user_display.dart';
import 'package:flutter/rendering.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context),
          );
        },
        child: const Icon(Icons.add, color: Colors.black,),
        backgroundColor: Colors.white,
      ),
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

Widget _buildPopupDialog(BuildContext context) {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Wrap (
              children: <Widget>[AmountCard()])
      )
  );
}