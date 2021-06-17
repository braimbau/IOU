import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/label_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'amount_input.dart';
import 'user.dart';
import 'selection.dart';

class PrefPicker extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> amountToPayPerUser = ValueNotifier(0);
    List<IOUser> selectedUsers = [];

    //if card is pre filled
    int amountToPay = 0;
    String label = "unamed quick pref";

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
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: AmountTextInput(changeATP: changeATP, isPreFilled: false, amount: 0,),
                  ),
                  SizedBox(
                    child: IconButton(
                      icon: const Icon(Icons.east, color: Colors.white),
                      onPressed: () {
                        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                        String err = amountError(amountToPay, selectedUsers.length);
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
                          addQuickPref("rfuvvQjatXbde1ZNL7O5", label,  "bite", amountToPay,  "bite");
                          //pop until main page to avoid poping only flushbar
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                          Flushbar(
                            message: "Quick pref $label is registred",
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
              LabelTextInput(isPreFilled: false, label: null, changeLabel: changeLabel,)
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


Future<void> addQuickPref(String groupId, String label, String users, int amount, String emoji) async {
  var  docRef = FirebaseFirestore.instance.collection('groups')
      .doc(groupId)
      .collection("quickadds").doc();
  docRef.set({'name': label, 'amount': amount, 'users' : users, 'emoji' : emoji});
}