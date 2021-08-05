import 'dart:ui';
import 'app_bar.dart';
import 'quick_card.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'amount_card.dart';
import 'balance_card.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'history.dart';
import 'Utils.dart';

//BuildContext context, IOUser usr, String group

class MainPageArgs {
  IOUser usr;
  String group;

  MainPageArgs({this.usr, this.group});
}

class MainPage extends StatefulWidget {
  final MainPageArgs args;

  MainPage({this.args});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  IOUser usr;
  String group;

  @override
  void initState() {
    usr = this.widget.args.usr;
    group = this.widget.args.group;
    updateUserInfosFromGroup(usr, group);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      onPanUpdate: (details) {
        if (details.delta.dy < -25) {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => History(usr: usr, group: group),
          );
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  _buildPopupDialog(context, usr, group),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.grey[900],
        appBar: topAppBar(usr, group, context),
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
              Visibility(child: Flexible(child: BalanceCard(usr: usr, group: group))),
              QuickCard(usr: usr, group: group),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildPopupDialog(BuildContext context, IOUser usr, String group) {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Wrap(children: <Widget>[AmountCard(currentUserId: usr.getId(), isPreFilled: false, group: group,)])));
}
