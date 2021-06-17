import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/label_input.dart';
import 'package:deed/payer_widget.dart';
import 'package:deed/quick_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'amount_input.dart';
import 'user.dart';
import 'selection.dart';

class AmountCard extends StatelessWidget {
  final IOUser currentUser;
  final QuickPref pref;
  final bool isPreFilled;

  AmountCard({@required this.currentUser, this.pref, this.isPreFilled});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> amountToPayPerUser = ValueNotifier(0);
    IOUser payer;
    List<IOUser> selectedUsers = [];

    //if card is pre filled
    int amountToPay = (isPreFilled) ? pref.getAmount() : 0;
    String label = (isPreFilled) ? pref.getName() : "unamed transaction";

    void updateAmountToPayPerUser()
    {
      if (selectedUsers.length == 0)
        amountToPayPerUser.value = -1;
      else
        amountToPayPerUser.value = amountToPay ~/ selectedUsers.length;
    }

    void changeATP(int value) {
      amountToPay = value;
      updateAmountToPayPerUser();
    }

    void changeLabel(String value) {
      label = value;
    }

    void addUserToSelected(IOUser usr)
    {
      selectedUsers.add(usr);
      updateAmountToPayPerUser();
    }

    void rmUserToSelected(IOUser usr)
    {
      selectedUsers.remove(usr);
      updateAmountToPayPerUser();
    }
    void setPayer(IOUser usr)
    {
      payer = usr;
    }

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

        List<IOUser> userList = List<IOUser>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++){
          userList.add(IOUser(snapshot.data.docs[i]["id"], snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }

        List<DropdownMenuItem<IOUser>> dropdownMenuItems = buildDropDownMenuItems(userList);

        if (isPreFilled) {
          pref.getUsers().split(":").forEach((element) {
            IOUser userToAdd = userList.firstWhere((el) => el.getId() == element, orElse: () => null);
            if (userToAdd != null)
              selectedUsers.add(userToAdd);
          }
          );
        }

        selectedUsers.removeWhere((element) => !userList.contains(element));
        return new Card(
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: PayerWidget(userList: userList, dropdownMenuItems: dropdownMenuItems, firstSelected: currentUser, setPayer: setPayer),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: AmountTextInput(changeATP: changeATP, isPreFilled: isPreFilled, amount: (isPreFilled) ? pref.getAmount() : 0,),
                  ),
                  SizedBox(
                    child: IconButton(
                      icon: const Icon(Icons.east, color: Colors.white),
                      onPressed: () {
                        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                        String err = amountError(amountToPay, selectedUsers.length);
                        int amountToCredit = 0;
                        if (err != null)
                        {
                          Flushbar(
                            message: err,
                            backgroundColor: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            icon: Icon(
                              Icons.error_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                            duration: Duration(seconds: 2),
                            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                          )..show(context);

                        }
                        else {
                          selectedUsers.forEach((element) {
                            changeBalance(element.getId(),
                                -amountToPay ~/ selectedUsers.length);
                            amountToCredit += amountToPay ~/ selectedUsers.length;
                          });
                          changeBalance(payer.getId(), amountToCredit);
                          newTransaction(amountToPay, amountToCredit, payer, selectedUsers, label);
                          amountToPayPerUser.value = 0;
                          amountToPay = 0;
                          //pop until main page to avoid poping only flushbar
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                          Flushbar(
                            message: "yeah",
                            backgroundColor: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            icon: Icon(
                              Icons.info_outline,
                              size: 28,
                              color: Colors.white,
                            ),
                            duration: Duration(seconds: 2),
                            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                          )..show(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ValueListenableBuilder(
                      valueListenable: amountToPayPerUser,
                      builder: (BuildContext context, int amount, Widget child) {
                        double dAmount = amount / 100;
                        return Text((amount > 0) ? " Each user owe $dAmount" : "", style: TextStyle(color: Colors.white));
                      }
                  )
                ],
              ),
              SizedBox(
                height: 75,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data.docs.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 4,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return SelectionWidget(user: userList[index], addUserToSelected: addUserToSelected, rmUserToSelected: rmUserToSelected, userSelected: selectedUsers);
                  },
                ),
              ),
              LabelTextInput(isPreFilled: isPreFilled, label: (isPreFilled) ? pref.getName() : null, changeLabel: changeLabel,)
            ],
          ),
        );
      },
    );
  }
}

String amountError(int amount, int nbUsers)
{
  if (nbUsers == 0)
    return ("You have to select at least one user");
  if (amount <= 0)
    return ("Enter an amount");
  if (amount ~/ nbUsers == 0)
    return ("Bro...");
  if (amount > 100000000)
    return ("You're not Jeff Bezos");
  return null;
}

Future<void> changeBalance(String id, int amount) async
{
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  ref.doc(id).update({"balance": FieldValue.increment(amount)});
}

Future<void> newTransaction(int displayedAmount, int actualAmount, IOUser payer, List<IOUser> selectedUsers, String label) async
{
  var timestamp = DateTime.now().millisecondsSinceEpoch;
  CollectionReference ref = FirebaseFirestore.instance.collection('transactions');
  //add transaction in global transaction list
  ref.doc(timestamp.toString()).set({'displayedAmount': displayedAmount, 'actualAmount': actualAmount, 'payer': payer.getName(), 'label': label,
    'amountPerUser': actualAmount/selectedUsers.length});
  selectedUsers.forEach((element) {
    int balanceEvo = - actualAmount ~/ selectedUsers.length;
    if (element == payer)
      balanceEvo += actualAmount;
    ref.doc(timestamp.toString()).collection('users').add({'name': element.getName()});
    String otherUsers = selectedUsers.where((el) => element != el).join(", ");
    //add transaction in users transaction list
    FirebaseFirestore.instance.collection('users').doc(element.getId()).collection('transactions').doc(timestamp.toString()).set({'transactionID':timestamp,
      'balanceEvo': balanceEvo, 'otherUsers': otherUsers, 'label': label, 'payer': payer.getName(), 'displayedAmount': displayedAmount});
  });
  //add transaction in payer transaction list
  if (!selectedUsers.contains(payer)) {
    String otherUsers = selectedUsers.where((el) => payer != el).join(", ");
    FirebaseFirestore.instance.collection('users').doc(payer.getId())
        .collection('transactions').doc(timestamp.toString())
        .set({
      'transactionID': timestamp,
      'balanceEvo': actualAmount,
      'otherUsers': otherUsers,
      'label': label,
      'payer': payer.getName(),
      'displayedAmount': displayedAmount
    });
  }
}

