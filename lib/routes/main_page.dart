import 'dart:ui';

import 'package:deed/balance/balance_display.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../Other/app_bar.dart';
import '../cards/quick_card.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../cards/amount_card.dart';
import '../classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Other/history.dart';
import '../Utils.dart';

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
    group = this.widget.args.group;
    usr = IOUser(this.widget.args.usr.getId(), "", "");
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
          ),
        ),
        appBar: topAppBar(usr, group, context),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.expand_less),
            Text(
              'Swipe up to show history',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ]),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: <Widget>[
              BalanceCard(usr: usr, group: group),
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
