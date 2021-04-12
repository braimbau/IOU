import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class User {
  num _balance;
  String _name;
  bool _isSelected;
  String _url;

  User(String name, String url) {
    this._name = name;
    this._url = url;
    this._isSelected = false;
    this._balance = 0;
  }

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

class _HomeState extends State<Home> {
  int amountToPay = 0;
  int amountToPayPerUser = 0;
  int nbSelectedUsers = 0;
  double displayableAmountToPayPerUser = 0;
  final myController = TextEditingController();
  List<User> userList = List<User>.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
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
              Card(
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: TextField(
                            style: TextStyle(color : Colors.black),
                            keyboardType: TextInputType.numberWithOptions(
                              signed: false,
                              decimal: true,
                            ),
                            controller: myController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter the amount to pay',
                                fillColor: Colors.white70,
                                filled: true),
                            onChanged: (String str) {setState(() {
                              double tmp;
                              try {
                                tmp = double.parse(str.replaceAll(',', '.')) * 100;
                              }
                              on Exception catch (_) {
                                amountToPay = -1;
                                return;
                              }
                              amountToPay = tmp.toInt();
                              if (nbSelectedUsers == 0)
                                amountToPay = -2;
                              else {
                                amountToPayPerUser = amountToPay ~/ nbSelectedUsers;
                                displayableAmountToPayPerUser = amountToPayPerUser / 100;
                              }
                            });},
                          ),
                        ),
                        SizedBox(
                          child: IconButton(
                            icon: const Icon(Icons.east, color: Colors.white),
                            onPressed: () {
                              setState(() {

                                userList.forEach((User usr) {
                                  if (usr._isSelected)
                                    usr.remBalance(amountToPayPerUser);
                                });

                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text((amountToPay >= 0)
                            ? "Each people owe $displayableAmountToPayPerUser euros"
                            : (amountToPay == -2) ? "please select user(s)" : "Enter an amount",style: TextStyle(color: Colors.white),)
                      ],
                    ),
                    SizedBox(
                      height: 75,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: userList.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 4,
                          );
                        },
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  userList[index].toggle();
                                  if (userList[index]._isSelected)
                                   nbSelectedUsers++;
                                  else
                                    nbSelectedUsers--;
                                  double tmp;
                                  try {
                                    tmp = double.parse(myController.text.replaceAll(',', '.')) * 100;
                                  }
                                  on Exception catch (_) {
                                    amountToPay = -1;
                                    return;
                                  }
                                  amountToPay = tmp.toInt();
                                  if (nbSelectedUsers == 0)
                                    amountToPay = -2;
                                  else {
                                    amountToPayPerUser = amountToPay ~/ nbSelectedUsers;
                                    displayableAmountToPayPerUser = amountToPayPerUser / 100;
                                  }
                                });
                              },
                              child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: (userList[index]._isSelected) ? Colors.blue : Colors.white,
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage:
                                        NetworkImage(userList[index]._url),
                                  )),
                            );
                          },
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      int i = 500 + userList.length;
                      userList.add(User("Gerard", "https://loremflickr.com/$i/$i"));

                    });
                  },
                  child: Text("Add new Gerad to users")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      userList.clear();
                      nbSelectedUsers = 0;
                    });
                  },
                  child: Text("Do a Geranocide")),
              SizedBox(
                height: 200,
                child : ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: userList.length,
                itemBuilder: (BuildContext context, int index)
                {
                  String name = userList[index]._name;
                  int balance = userList[index]._balance;
                  return Text("$name : $balance centimes", style: TextStyle(color : Colors.white));
                },
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
