import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user.dart';

class AmountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> amountToPayPerUser = ValueNotifier(0);
    int amountToPay = 0;
    IOUser payer;
    List<IOUser> selectedUsers = [];

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
        print("yo, jme rebuild");
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
        selectedUsers.removeWhere((element) => !userList.contains(element));
        return new Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
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
                child: PayerWidget(userList: userList, dropdownMenuItems: dropdownMenuItems, firstSelected: userList[0], setPayer: setPayer),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: AmountTextInput(changeATP: changeATP),
                  ),
                  SizedBox(
                    child: IconButton(
                      icon: const Icon(Icons.east, color: Colors.white),
                      onPressed: () {
                        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                        print(selectedUsers.length);
                        String err = amountError(amountToPay, selectedUsers.length);
                        int amountToCredit = 0;
                        if (err != null)
                        {
                          final snackBar = SnackBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                            content: Text(err),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        else {
                          selectedUsers.forEach((element) {
                            changeBalance(element.getId(),
                                -amountToPay ~/ selectedUsers.length);
                            amountToCredit += amountToPay ~/ selectedUsers.length;
                          });
                          changeBalance(payer.getId(), amountToCredit);
                          newTransaction(amountToPay, amountToCredit, payer, selectedUsers, "unamed transaction");
                          amountToPayPerUser.value = 0;
                          amountToPay = 0;
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
              )
            ],
          ),
        );
      },
    );
  }
}

class PayerWidget extends StatefulWidget {
  final List<IOUser> userList;
  final List<DropdownMenuItem<IOUser>> dropdownMenuItems;
  final IOUser firstSelected;
  final void Function(IOUser usr) setPayer;

  PayerWidget({this.userList, this.dropdownMenuItems, this.firstSelected, this.setPayer});
  @override
  _PayerWidgetState createState() => _PayerWidgetState();
}

class _PayerWidgetState extends State<PayerWidget> {
  IOUser  selectedItem;

  @override
  Widget build(BuildContext context) {
    if (!this.widget.userList.contains(selectedItem)) {
      selectedItem = this.widget.firstSelected;
      this.widget.setPayer(selectedItem);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: DropdownButton<IOUser>(
          value: selectedItem,
          items: this.widget.dropdownMenuItems,
          selectedItemBuilder: (_) {
            return this.widget.userList
                .map((e) => Container(
              width: 170,
              alignment: Alignment.centerLeft,
              child: Text(selectedItem.getName(),
                style: TextStyle(color: Colors.white),
              ),
            ))
                .toList();
          },
          onChanged: (value) {
            setState(() {
              selectedItem = value;
              this.widget.setPayer(selectedItem);
            });
          }),
    );
  }
}

class PayerDropDown extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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

        return new PayerWidget(userList: userList, dropdownMenuItems: dropdownMenuItems);
      },
    );
  }
}

List<DropdownMenuItem<IOUser>> buildDropDownMenuItems(List listItems) {
  List<DropdownMenuItem<IOUser>> items = List();
  for (IOUser listItem in listItems) {
    items.add(
      DropdownMenuItem(
        child: Row(
            children:<Widget>[
              CircleAvatar(
                radius: 15,
                backgroundImage:
                NetworkImage(listItem.getUrl()),
              ),
              Text(listItem.getName(),
                  style : TextStyle(color: Colors.black,))
            ]),
        value: listItem,
      ),
    );
  }
  return items;
}

class SelectionWidget extends StatefulWidget {
  final IOUser user;
  final List<IOUser> userSelected;
  final void Function(IOUser usr) addUserToSelected;
  final void Function(IOUser usr) rmUserToSelected;

  SelectionWidget({this.user, this.addUserToSelected, this.rmUserToSelected, this.userSelected});
  @override
  _SelectionWidgetState createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  bool isSelected;

  @override
  Widget build(BuildContext context) {
    isSelected = this.widget.userSelected.contains(this.widget.user);
    return InkWell(
        onTap: () {
          setState(() {
            this.isSelected = !this.isSelected;
            if (isSelected)
              this.widget.addUserToSelected(this.widget.user);
            else {
              this.widget.rmUserToSelected(this.widget.user);
            }
          });
        },
        child: CircleAvatar(
            radius: 25,
            backgroundColor: (this.isSelected) ? Colors.blue : Colors.white,
            child: CircleAvatar(radius: 22,  backgroundImage: NetworkImage(this.widget.user.getUrl()))
        )
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
    String otherUsers = selectedUsers.where((el) => element != el).join(" ");
    //add transaction in users transaction list
    FirebaseFirestore.instance.collection('users').doc(element.getId()).collection('transactions').doc(timestamp.toString()).set({'transactionID':timestamp,
      'balanceEvo': balanceEvo, 'otherUsers': otherUsers, 'label': label, 'payer': payer.getName(), 'displayedAmount': displayedAmount});
  });
  //add transaction in payer transaction list
  if (!selectedUsers.contains(payer)) {
    String otherUsers = selectedUsers.where((el) => payer != el).join(" ");
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

class AmountTextInput extends StatefulWidget {
  final void Function(int value) changeATP;
  final controller = TextEditingController();

  AmountTextInput({this.changeATP});
  @override
  _AmountTextInputState createState() => _AmountTextInputState();
}

class _AmountTextInputState extends State<AmountTextInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        style: TextStyle(color : Colors.black),
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: true,
        ),
        controller: this.widget.controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter the amount to pay',
            fillColor: Colors.white70,
            filled: true),
        onChanged: (String str) {
          setState(() {
            double tmp;
            try {
              tmp = double.parse(str.replaceAll(',', '.')) * 100;
              this.widget.changeATP(tmp.toInt());
            }
            on Exception catch (_) {
              this.widget.changeATP(-1);
              return;
            }
            this.widget.changeATP(tmp.toInt());
          });
        });
  }
}