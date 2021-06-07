import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';
//import 'history.dart';
import 'user.dart';
import 'oauth.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override

  _HomeState createState() => _HomeState();
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

class _HomeState extends State<Home> {
  AmountInfo amountInfo;
  double price = 0;


  void initState() {
  }

  void changePrice(double value)
  {
    price = value;
  }

Widget mainPage(BuildContext context) {
    amountInfo = AmountInfo();
  return GestureDetector(
    onTap: () {
      print("test");
      //FocusScope.of(context).requestFocus(new FocusNode());
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    },
    child: Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('IOU'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ListView(
          children: <Widget> [

            SizedBox(
              height: 200,
              child : BalanceList()
            ),
            Text(amountInfo.total.toString()),
            AmountCard(),
            TextButton(
                onPressed: () {
                    Random random = new Random();
                    int i = 500 + random.nextInt(500);
                    String name = "Gerard " + i.toString();
                    createUser(name, "https://loremflickr.com/$i/$i");
                },
                child: Text("Add new Gerad to users")),
            History(id: "X6hUIpBF4xMhlFImdcDi"),
          ],
        ),
      ),
    ),
  );
}

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Text("C'est la merde");
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return mainPage(context);
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Text("Ca charge bro attend");
        },
      );
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


class BalanceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("stream2");
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

        return new ListView.builder(
          itemCount: snapshot.data.docs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index)
          {
            String name = snapshot.data.docs[index]['name'];
            int balance = snapshot.data.docs[index]['balance'];
            return Text("$name : $balance centimes", style: TextStyle(color : (balance == 0) ? Colors.white : (balance > 0) ? Colors.green : Colors.red));
          },
        );
      },
    );
  }
}

Future<void> createUser(String name, String url) async
{
  var  docRef = FirebaseFirestore.instance.collection('users').doc();
  docRef.set({'name': name, 'balance': 0, 'url' : url, 'id': docRef.id});
}

Future<void> changeBalance(String id, int amount) async
{
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  ref.doc(id).update({"balance": FieldValue.increment(amount)});
}

Future<void> newTransaction(int displayedAmount, int actualAmount, User payer, List<User> selectedUsers, String label) async
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

class AmountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> amountToPayPerUser = ValueNotifier(0);
    int amountToPay = 0;
    User payer;
    List<User> selectedUsers = [];

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

    void addUserToSelected(User usr)
    {
      selectedUsers.add(usr);
      updateAmountToPayPerUser();
    }

    void rmUserToSelected(User usr)
    {
      selectedUsers.remove(usr);
      updateAmountToPayPerUser();
    }
    void setPayer(User usr)
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

        List<User> userList = List<User>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++){
          userList.add(User(snapshot.data.docs[i]["id"], snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }
        List<DropdownMenuItem<User>> dropdownMenuItems = buildDropDownMenuItems(userList);
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
                    return Text((amount > 0) ? "Each user owe $dAmount" : "", style: TextStyle(color: Colors.white));
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

class SelectionWidget extends StatefulWidget {
  final User user;
  final List<User> userSelected;
  final void Function(User usr) addUserToSelected;
  final void Function(User usr) rmUserToSelected;

  SelectionWidget({this.user, this.addUserToSelected, this.rmUserToSelected, this.userSelected});
  @override
  _SelectionWidgetState createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  bool isSelected;

  void initState() {
  }
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
              print("tamer");
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
  if (amount > 1000000)
      return ("You're not Jeff Bezos");
  return null;
}

class PayerWidget extends StatefulWidget {
  final List<User> userList;
  final List<DropdownMenuItem<User>> dropdownMenuItems;
  final User firstSelected;
  final void Function(User usr) setPayer;

  PayerWidget({this.userList, this.dropdownMenuItems, this.firstSelected, this.setPayer});
  @override
  _PayerWidgetState createState() => _PayerWidgetState();
}

class _PayerWidgetState extends State<PayerWidget> {
  User  selectedItem;

  @override
  Widget build(BuildContext context) {
   if (!this.widget.userList.contains(selectedItem)) {
      selectedItem = this.widget.firstSelected;
      this.widget.setPayer(selectedItem);
    }
    return DropdownButton<User>(
        value: selectedItem,
        items: this.widget.dropdownMenuItems,
        selectedItemBuilder: (_) {
          return this.widget.userList
              .map((e) => Container(
            alignment: Alignment.centerLeft,
            width: 100,
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
        });
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

        List<User> userList = List<User>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++){
          userList.add(User(snapshot.data.docs[i]["id"], snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }
        List<DropdownMenuItem<User>> dropdownMenuItems = buildDropDownMenuItems(userList);

        return new PayerWidget(userList: userList, dropdownMenuItems: dropdownMenuItems);
      },
    );
  }
}

List<DropdownMenuItem<User>> buildDropDownMenuItems(List listItems) {
  List<DropdownMenuItem<User>> items = List();
  for (User listItem in listItems) {
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





