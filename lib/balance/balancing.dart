import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'Balancing_option.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Balancing extends StatefulWidget {
  final BalancingArgs args;

  Balancing({this.args});

  @override
  _BalancingState createState() => _BalancingState();
}

class _BalancingState extends State<Balancing> {
  List<List<UserBalance>> balancingOptions;
  int picked;

  void resetPicked() {
    setState(() {
      picked = null;
    });
  }

  @override
  void initState() {
    updateBalancingOptions(
        this.widget.args.groupId, this.widget.args.usr.getId());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IOUser usr = this.widget.args.usr;
    String groupId = this.widget.args.groupId;

    AppLocalizations t = AppLocalizations.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      semanticContainer: true,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.balancingOptions,
              style: Theme.of(context).textTheme.headline1,
            ),
            Divider(
              thickness: 2,
            ),
            if (balancingOptions == null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                semanticContainer: true,
                elevation: 5,
                color: Theme.of(context).appBarTheme.backgroundColor,
                child: Container(
                  height: 78,
                  child: Text(t.loading),
                ),
              ),
            if (balancingOptions != null && balancingOptions.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                semanticContainer: true,
                elevation: 5,
                color: Theme.of(context).appBarTheme.backgroundColor,
                child: Container(
                  height: 78,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      Text(
                        "You're all set !",
                        style: TextStyle(color: Colors.green),
                      )
                    ],
                  ),
                ),
              ),
            if (balancingOptions != null && balancingOptions.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: balancingOptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Visibility(
                      visible: picked == null || picked == index,
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              picked = index;
                            });
                          },
                          child: BalancingOptionCard(
                            balancing: balancingOptions[index],
                            isBest: (index == 0),
                            isDeployed: (picked == index),
                            resetPicked: resetPicked,
                            group: groupId,
                            usr: usr,
                            updateBalancingOptions: updateBalancingOptions,
                          )),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void updateBalancingOptions(String groupId, String usrId) async {
    List<UserBalance> list = await getUserBalances(groupId);
    int usrBalance =
        list.firstWhere((element) => element.getId() == usrId).getBalance();
    list.removeWhere((element) => element.getId() == usrId);
    List<List<UserBalance>> _balancingOptions = [];
    if (usrBalance > 0) {
      list.removeWhere((element) => element.getBalance() >= 0);
      list.sort(compareBalancesDec);
      int index = 0;
      while (list.isNotEmpty) {
        List<UserBalance> balancingOption = [];
        _balancingOptions.add(balancingOption);
        int tUsrBalance = usrBalance;
        while (tUsrBalance > 0 && list.isNotEmpty) {
          if (tUsrBalance <= -list.first._balance) {
            list.first._balance = -tUsrBalance;
            tUsrBalance = 0;
            _balancingOptions[index].add(list.first);
            list.removeAt(0);
          } else {
            tUsrBalance += list.first._balance;
            _balancingOptions[index].add(list.first);
            list.removeAt(0);
          }
        }
        if (tUsrBalance != 0) _balancingOptions.removeAt(index);
        index++;
      }
    } else {
      list.removeWhere((element) => element.getBalance() <= 0);
      list.sort(compareBalancesInc);
      int index = 0;
      while (list.isNotEmpty) {
        List<UserBalance> balancingOption = [];
        _balancingOptions.add(balancingOption);
        int tUsrBalance = usrBalance;
        while (tUsrBalance < 0 && list.isNotEmpty) {
          if (-tUsrBalance <= list.first._balance) {
            list.first._balance = -tUsrBalance;
            tUsrBalance = 0;
            _balancingOptions[index].add(list.first);
            list.removeAt(0);
          } else {
            tUsrBalance += list.first._balance;
            _balancingOptions[index].add(list.first);
            list.removeAt(0);
          }
        }
        if (tUsrBalance != 0) _balancingOptions.removeAt(index);
        index++;
      }
    }
    setState(() {
      balancingOptions = _balancingOptions;
      print(balancingOptions);
    });
  }
}

Future<List<UserBalance>> getUserBalances(String group) async {
  List<UserBalance> balanceList = [];

  CollectionReference ref = FirebaseFirestore.instance
      .collection('groups')
      .doc(group)
      .collection("users");
  QuerySnapshot snap = await ref.get();
  snap.docs.forEach((element) {
    balanceList.add(UserBalance(
        element['balance'], element['name'], element.id, element['url']));
  });
  return balanceList;
}

int compareBalancesDec(UserBalance a, UserBalance b) {
  return a._balance - b._balance;
}

int compareBalancesInc(UserBalance a, UserBalance b) {
  return b._balance - a._balance;
}

class UserBalance {
  int _balance;
  String _name;
  String _id;
  String _url;

  UserBalance(int balance, String name, String id, String url) {
    _balance = balance;
    _name = name;
    _id = id;
    _url = url;
  }

  int getBalance() {
    return _balance;
  }

  String getName() {
    return _name;
  }

  String getId() {
    return _id;
  }

  String getUrl() {
    return _url;
  }

  void setUrl(String url) {
    _url = url;
  }

  @override
  String toString() {
    return '$_name : $_balance';
  }
}

class BalancingArgs {
  IOUser usr;
  String groupId;

  BalancingArgs({this.usr, this.groupId});
}
