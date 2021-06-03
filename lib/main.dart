import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';


void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override

  _HomeState createState() => _HomeState();
}

int i = 0;

class User {
  double _balance;
  String _name;
  bool _isSelected;
  String _url;

  User(String name, String url) {
    this._name = name;
    this._url = url;
    this._isSelected = false;
    this._balance = 0;
  }

  @override
  bool operator==(other) => other._name == _name;

  addBalance(int n) {
    _balance += n;
  }

  remBalance(int n)
  {
    _balance -= n;
  }

  toggle() {
    _isSelected = !_isSelected;
  }
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
           /* Card(
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
                    child: Text("Payer Dropdown"),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: AmountTextInput(amountInfo: amountInfo, changePrice: changePrice,),
                      ),
                      SizedBox(
                        child: IconButton(
                          icon: const Icon(Icons.east, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              print(amountInfo.total);
                              print("price2 $price");

                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("yo")
                    ],
                  ),
                  BalanceUser()
                ],
              ),
            ),*/
            SizedBox(
              height: 200,
              child : BalanceList()
            ),
            Text(amountInfo.total.toString()),
            AmountCard(),
            TextButton(
                onPressed: () {
                    Random random = new Random();
                    int randomNumber = random.nextInt(100);
                    int i = 500 + random.nextInt(500);
                    String name = "Gerard " + i.toString();
                    createUser(name, "https://loremflickr.com/$i/$i");
                },
                child: Text("Add new Gerad to users")),
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

class BalanceUser extends StatelessWidget {
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

        print(snapshot.data.docs.length);
        return new SizedBox(
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
             // return SelectionWidget(url:snapshot.data.docs[index]["url"]);
            },
          ),
        );

      },
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

        List<User> userList = List<User>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++){
          userList.add(User(snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }
        List<DropdownMenuItem<User>> dropdownMenuItems = buildDropDownMenuItems(userList);

        return new PayerWidget(userList: userList, dropdownMenuItems: dropdownMenuItems);
      },
    );
  }
}


Future<void> createUser(String name, String url) async
{
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  ref.doc(name).set({'name': name, 'balance': 0, 'url' : url});
  print("a");
}

Future<void> changeBalance(String name, int amount) async
{
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  ref.doc(name).update({"balance": FieldValue.increment(amount)});
  print("B");
}

Future<void> getUsers(List<User> userList) async
{
  Firebase.initializeApp();
  CollectionReference reference = FirebaseFirestore.instance.collection('users');
  print("yo\n");
  reference.snapshots().listen((querySnapshot) {
    querySnapshot.docChanges.forEach((change) {
      print(change);
    });
  });
}

class SelectionWidget extends StatefulWidget {
  final List<User> userList;
  final List<User> userSelected;
  final int index;
  final void Function(User usr) addUserToSelected;
  final void Function(User usr) rmUserToSelected;

  SelectionWidget({this.userList, this.index, this.addUserToSelected, this.rmUserToSelected, this.userSelected});
  @override
  _SelectionWidgetState createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  bool isSelected;

  void initState() {
    isSelected = this.widget.userSelected.contains(this.widget.userList[this.widget.index]);
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            this.isSelected = !this.isSelected;
            if (isSelected)
              this.widget.addUserToSelected(this.widget.userList[this.widget.index]);
            else {
              this.widget.rmUserToSelected(this.widget.userList[this.widget.index]);
              print("tamer");
            }
          });
        },
        child: CircleAvatar(
            radius: 25,
            backgroundColor: (this.isSelected) ? Colors.blue : Colors.white,
            child: CircleAvatar(radius: 22,  backgroundImage: NetworkImage(this.widget.userList[this.widget.index]._url))
        )
    );
  }
}

class AmountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("NAAANNNNN");
    int amountToPay = 0;
    User payer;
    void changeATP(int value) {
      amountToPay = value;
    }
    List<User> selectedUsers = [];

    void addUserToSelected(User usr)
    {
      selectedUsers.add(usr);
    }

    void rmUserToSelected(User usr)
    {
      selectedUsers.remove(usr);
    }
    void setPayer(User usr)
    {
      payer = usr;
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        print("stream");
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
          userList.add(User(snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }
        List<DropdownMenuItem<User>> dropdownMenuItems = buildDropDownMenuItems(userList);

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
                          print("amount = $amountToPay");
                          if (selectedUsers.length == 0) {
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                              content: Text("You have to select at least one user"),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else if (amountToPay <= 0){
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                              content: Text("Enter an amount"),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else {
                            selectedUsers.forEach((element) {
                              changeBalance(element._name,
                                  -amountToPay ~/ selectedUsers.length.toInt());
                            });
                            changeBalance(payer._name, amountToPay);
                          }
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Each User owe $amountToPay", style: TextStyle(color: Colors.white))
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
                    return SelectionWidget(userList: userList, index: index, addUserToSelected: addUserToSelected, rmUserToSelected: rmUserToSelected, userSelected: selectedUsers);
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
            child: Text(selectedItem._name,
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
                NetworkImage(listItem._url),
              ),
              Text(listItem._name,
                  style : TextStyle(color: Colors.black,))
            ]),
        value: listItem,
      ),
    );
  }
  return items;
}