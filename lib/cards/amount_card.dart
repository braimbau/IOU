import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/Utils.dart';
import 'package:deed/utils/transaction_utils.dart';

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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AmountCard extends StatelessWidget {
  final String currentUserId;
  final QuickPref pref;
  final bool isPreFilled;
  final String group;

  AmountCard(
      {@required this.currentUserId, this.pref, this.isPreFilled, this.group});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context);

    ValueNotifier<int> amountToPayPerUser = ValueNotifier(0);
    ValueNotifier<int> amountToPay = ValueNotifier(0);
    ValueNotifier<String> secondaryDisplay = ValueNotifier("");
    IOUser payer;
    List<IOUser> selectedUsers = [];

    //if card is pre filled
    String label = (isPreFilled) ? pref.getName() : t.unnamedTransaction;
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
          (amountToPayPerUser.value > 0) ? t.usersOwe + "$dAmount" : "";
        }
      } else {
        amountToPayPerUser.value = inputInfo.getAmount();
        amountToPay.value = amountToPayPerUser.value * selectedUsers.length;
        double dAmount = amountToPay.value / 100;
        secondaryDisplay.value =
        (amountToPay.value > 0) ? t.totalAmount + "$dAmount" : "";
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
      stream: FirebaseFirestore.instance
          .collection("groups")
          .doc(group)
          .collection("users")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(t.err1);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(t.loading);
        }

        if (snapshot.data.docs.length == 0) return Text(t.noUsers);

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

        selectedUsers.removeWhere((element) => !userList.contains(element));
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Theme
                  .of(context)
                  .primaryColor,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          semanticContainer: true,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Payer:",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText2,
                    ),
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
                        icon: const Icon(Icons.east),
                        onPressed: () async {
                          WidgetsBinding.instance.focusManager.primaryFocus
                              ?.unfocus();
                          String err = amountError(
                              amountToPay.value, selectedUsers.length, t);
                          if (err != null) {
                            displayError(err, context);
                            return;
                          }
                          err = await runTransactionToUpdateBalances(
                              selectedUsers,
                              group,
                              amountToPay.value,
                              payer, t);
                          if (err != null) {
                            displayError(err, context);
                            return;
                          }
                          newTransaction(
                              amountToPay.value,
                              amountToPay.value ~/ selectedUsers.length *
                                  selectedUsers.length,
                              payer,
                              selectedUsers,
                              label,
                              group,
                              currentUserId);
                          Navigator.of(context).popUntil(
                              ModalRoute.withName('/mainPage'));
                          displayMessage(t.transactionConfirmed, context);
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
                          return Visibility(
                            visible: (text != null && text != ""),
                            child: Text(text, style: Theme
                                .of(context)
                                .textTheme
                                .bodyText1,),
                          );
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


  String amountError(int amount, int nbUsers, AppLocalizations t) {
    if (nbUsers == 0) return (t.amountError1);
    if (amount <= 0) return (t.amountError2);
    if (amount ~/ nbUsers == 0) return (t.amountError3);
    if (amount > 100000000) return (t.amountError4);
    return null;
  }

  Future<void> changeBalance(String id, int amount, String group) async {
    CollectionReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection("groups");
    ref.doc(group).update({"balance": FieldValue.increment(amount)});
  }

  Future<void> newTransaction(int displayedAmount, int actualAmount,
      IOUser payer,
      List<IOUser> selectedUsers, String label, String group,
      String transactorId) async {
    String users = selectedUsers.join(":");
    var timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
    CollectionReference ref =
    FirebaseFirestore.instance.collection('groups').doc(group).collection(
        'transactions');
    //add transaction in group transaction list
    ref.doc(timestamp.toString()).set({
      'displayedAmount': displayedAmount,
      'actualAmount': actualAmount,
      'selectedUsers': users,
      'payer': payer.getId(),
      'label': label,
      'amountPerUser': actualAmount / selectedUsers.length,
      'transactor': transactorId,
      'time': DateTime
          .now()
          .millisecondsSinceEpoch,
    });
    selectedUsers.forEach((element) {
      int balanceEvo = -actualAmount ~/ selectedUsers.length;
      if (element == payer) balanceEvo += actualAmount;
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
        'selectedUsers': users,
        'label': label,
        'payer': payer.getId(),
        'displayedAmount': displayedAmount,
        'actualAmount': actualAmount,
        'transactor': transactorId,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
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
        'selectedUsers': users,
        'label': label,
        'payer': payer.getId(),
        'displayedAmount': displayedAmount,
        'actualAmount': actualAmount,
        'transactor': transactorId,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
    }
  }

  onValidation(ValueNotifier<int> amountToPay,
      List<IOUser> selectedUsers,
      BuildContext context,
      IOUser payer,
      String label,
      ValueNotifier<int> amountToPayPerUser,
      String group) async {

    AppLocalizations t = AppLocalizations.of(context);

    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    String err = amountError(amountToPay.value, selectedUsers.length, t);

    if (err == null)
      err = await runTransactionToUpdateBalances(
          selectedUsers, group, amountToPay.value, payer, t);

    if (err != null) {
      displayError(err, context);

      amountToPayPerUser.value = 0;
      amountToPay.value = 0;
    } else {
      //pop until main page to avoid poping only flushbar
      Navigator.of(context).popUntil(ModalRoute.withName('/mainPage'));
      displayMessage(t.yeah, context);
    }
  }

  Future<String> runTransactionToUpdateBalances(List<IOUser> selectedUsers,
      String group, int amountToPay, IOUser payer, AppLocalizations t) async {
    final db = FirebaseFirestore.instance;
    return await db.runTransaction((Transaction tr) async {
      if (!await checkUsersInGroupT(tr, selectedUsers, group))
        return t.userNotInGroup;
      int amountToCredit =
          amountToPay ~/ selectedUsers.length * selectedUsers.length;

      selectedUsers.forEach((element) async {
        await changeBalanceT(
            tr, element.getId(), -amountToPay ~/ selectedUsers.length, group);
        amountToCredit += amountToPay ~/ selectedUsers.length;
      });
      await changeBalanceT(tr, payer.getId(), amountToCredit, group);
      return null;
    }).then((value) {
      return value;
    }).catchError((error) {
      return t.err2;
    });
  }