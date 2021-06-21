import 'dart:ui';
import 'package:deed/app_bar.dart';
import 'package:deed/quick_card.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'amount_card.dart';
import 'balance_card.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'history.dart';

Widget mainPage(BuildContext context, IOUser usr) {
  return GestureDetector(
    onTap: () {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    },
    onPanUpdate: (details) {
      if (details.delta.dy < -25) {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => History(usr: usr),
        );
      }
    },
    child: Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context, usr),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[900],
      appBar: topAppBar(usr),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.expand_less, color: Colors.white),
          Text(
            'Swipe up to show history',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ]),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: <Widget>[
            Flexible(child: BalanceCard(usr: usr)),
            QuickCard(usr: usr),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPopupDialog(BuildContext context, IOUser usr) {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Wrap(children: <Widget>[AmountCard(currentUser: usr, isPreFilled: false,)])));
}
