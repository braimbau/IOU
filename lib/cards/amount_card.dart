import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/Utils.dart';

import '../classes/InputInfo.dart';
import '../utils/error.dart';
import 'label_input.dart';
import 'payer_widget.dart';
import '../classes/quick_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'amount_input.dart';
import '../classes/user.dart';
import 'selection.dart';

class AmountCard extends StatelessWidget {
  final String currentUserId;
  final QuickPref pref;
  final bool isPreFilled;
  final String group;

  AmountCard(
      {@required this.currentUserId, this.pref, this.isPreFilled, this.group});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> amountToPayPerUser = ValueNotifier(0);
    ValueNotifier<int> amountToPay = ValueNotifier(0);
    ValueNotifier<String> secondaryDisplay = ValueNotifier("");
    IOUser payer;
    List<IOUser> selectedUsers = [];

    //if card is pre filled
    String label = (isPreFilled) ? pref.getName() : "unnamed transaction";
    InputInfo inputInfo =
        InputInfo(false, (isPreFilled) ? pref.getAmount() : 0);

    void updateAmountToPay() {
      if (inputInfo.getIsIndividual() == false) {
        amountToPay.value = inputInfo.getAmount();
        if (selectedUsers.length == 0) {
          amountToPayPerUser.value = -1;
          secondaryDisplay.value = "";
        } else {
          amountToPayPerUser.value = amountToPay.value ~/ selectedUsers.length;
          double dAmount = amountToPayPerUser.value / 100;
          secondaryDisplay.value =
              (amountToPayPerUser.value > 0) ? " Each user owe $dAmount" : "";
        }
      } else {
        amountToPayPerUser.value = inputInfo.getAmount();
        amountToPay.value = amountToPayPerUser.value * selectedUsers.length;
        double dAmount = amountToPay.value / 100;
        secondaryDisplay.value =
            (amountToPay.value > 0) ? " The total amount is $dAmount" : "";
      }
    }

    void changeInputInfo(InputInfo ii) {
      inputInfo = ii;
      updateAmountToPay();
    }

    void changeLabel(String value) {
      label = value;
    }

    void addUserToSelected(IOUser usr) {
      selectedUsers.add(usr);
      updateAmountToPay();
    }

    void rmUserToSelected(IOUser usr) {
      selectedUsers.remove(usr);
      updateAmountToPay();
    }

    void setPayer(IOUser usr) {
      payer = usr;
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("groups").doc(group).collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        if (snapshot.data.docs.length == 0) return Text("No users to display");

        List<IOUser> userList = List<IOUser>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          userList.add(IOUser(snapshot.data.docs[i]["id"],
              snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }

        List<DropdownMenuItem<IOUser>> dropdownMenuItems =
            buildDropDownMenuItems(userList);

        if (isPreFilled) {
          pref.getUsers().split(":").forEach((element) {
            IOUser userToAdd = userList
                .firstWhere((el) => el.getId() == element, orElse: () => null);
            if (userToAdd != null) selectedUsers.add(userToAdd);
          });
          updateAmountToPay();
        }

        print("selected : $currentUserId");
        selectedUsers.removeWhere((element) => !userList.contains(element));
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.grey[900],
          semanticContainer: true,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Payer:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    PayerWidget(
                        userList: userList,
                        dropdownMenuItems: dropdownMenuItems,
                        firstSelected: userList.firstWhere(
                            (element) => element.getId() == currentUserId),
                        setPayer: setPayer),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: AmountTextInput(
                        changeInputInfo: changeInputInfo,
                        isPreFilled: isPreFilled,
                        amount: (isPreFilled) ? pref.getAmount() : 0,
                      ),
                    ),
                    SizedBox(
                      child: IconButton(
                        icon: const Icon(Icons.east, color: Colors.white),
                        onPressed: () async {
                          onValidation(amountToPay, selectedUsers, context,
                              payer, label, amountToPayPerUser, group);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: secondaryDisplay,
                        builder:
                            (BuildContext context, String text, Widget child) {
                          return Text(text,
                              style: TextStyle(color: Colors.white));
                        }),
                  ],
                ),
                SizedBox(
                  height: 65,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(0),
                    itemCount: snapshot.data.docs.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        width: 4,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return SelectionWidget(
                          user: userList[index],
                          addUserToSelected: addUserToSelected,
                          rmUserToSelected: rmUserToSelected,
                          userSelected: selectedUsers);
                    },
                  ),
                ),
                LabelTextInput(
                  isPreFilled: isPreFilled,
                  label: (isPreFilled) ? pref.getName() : null,
                  changeLabel: changeLabel,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

String amountError(int amount, int nbUsers) {
  if (nbUsers == 0) return ("You have to select at least one user");
  if (amount <= 0) return ("Enter an amount");
  if (amount ~/ nbUsers == 0) return ("Bro...");
  if (amount > 100000000) return ("You're not Jeff Bezos");
  return null;
}

Future<void> changeBalance(String id, int amount, String group) async {
  CollectionReference ref = FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .collection("groups");
  ref.doc(group).update({"balance": FieldValue.increment(amount)});
}

Future<void> newTransaction(int displayedAmount, int actualAmount, IOUser payer,
    List<IOUser> selectedUsers, String label, String group) async {
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  CollectionReference ref =
      FirebaseFirestore.instance.collection('transactions');
  //add transaction in global transaction list
  ref.doc(timestamp.toString()).set({
    'displayedAmount': displayedAmount,
    'actualAmount': actualAmount,
    'payer': payer.getName(),
    'label': label,
    'amountPerUser': actualAmount / selectedUsers.length
  });
  String users = selectedUsers.join(":");
  selectedUsers.forEach((element) {
    int balanceEvo = -actualAmount ~/ selectedUsers.length;
    if (element == payer) balanceEvo += actualAmount;
    ref
        .doc(timestamp.toString())
        .collection('users')
        .add({'name': element.getName()});
    //add transaction in users transaction list
    FirebaseFirestore.instance
        .collection('users')
        .doc(element.getId())
        .collection("groups")
        .doc(group)
        .collection('transactions')
        .doc(timestamp.toString())
        .set({
      'transactionID': timestamp,
      'balanceEvo': balanceEvo,
      'otherUsers': users,
      'label': label,
      'payer': payer.getName(),
      'displayedAmount': displayedAmount
    });
  });
  //add transaction in payer transaction list
  if (!selectedUsers.contains(payer)) {
    String users = selectedUsers.join(":");
    FirebaseFirestore.instance
        .collection('users')
        .doc(payer.getId())
        .collection("groups")
        .doc(group)
        .collection('transactions')
        .doc(timestamp.toString())
        .set({
      'transactionID': timestamp,
      'balanceEvo': actualAmount,
      'otherUsers': users,
      'label': label,
      'payer': payer.getName(),
      'displayedAmount': displayedAmount
    });
  }
}

onValidation(
    ValueNotifier<int> amountToPay,
    List<IOUser> selectedUsers,
    BuildContext context,
    IOUser payer,
    String label,
    ValueNotifier<int> amountToPayPerUser,
    String group) async {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  String err = amountError(amountToPay.value, selectedUsers.length);
  if (err == null)
    err = await checkUsersInGroup(selectedUsers, group) ? null : "An user isn't in the group anymore";
  int amountToCredit = 0;
  if (err != null) {
    displayError(err, context);
  } else {
    selectedUsers.forEach((element) {
      changeBalance(
          element.getId(), -amountToPay.value ~/ selectedUsers.length, group);
      amountToCredit += amountToPay.value ~/ selectedUsers.length;
    });
    changeBalance(payer.getId(), amountToCredit, group);
    newTransaction(
        amountToPay.value, amountToCredit, payer, selectedUsers, label, group);
    amountToPayPerUser.value = 0;
    amountToPay.value = 0;
    //pop until main page to avoid poping only flushbar
    Navigator.of(context).popUntil(ModalRoute.withName('/mainPage'));
    displayMessage("yeah", context);
  }
}
