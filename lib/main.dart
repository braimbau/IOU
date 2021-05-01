import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

int i = 0;

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
  List<User> userList = [User("Gertrude", "https://loremflickr.com/500/500")];
  List<String> userNameList = List<String>.empty(growable: true);


  List<DropdownMenuItem<User>> _dropdownMenuItems;
  User _selectedItem;

  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(userList);
    _selectedItem = _dropdownMenuItems[0].value;
    Theme theme;

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

Widget mainPage(BuildContext context){
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
                  Align(
                    alignment: Alignment.topLeft,
                    child: DropdownButton<User>(
                        value: _selectedItem,
                        items: _dropdownMenuItems,
                        selectedItemBuilder: (_) {
                          return userList
                              .map((e) => Container(
                            alignment: Alignment.centerLeft,
                            width: 100,
                            child: Text(_selectedItem._name,
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                              .toList();
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedItem = value;
                          });
                        }),
                  ),
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
                              _selectedItem.addBalance(amountToPay);
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
                    String name = "Gerard " + i.toString();
                    userList.add(User(name, "https://loremflickr.com/$i/$i"));
                    userNameList.add(name);
                    _dropdownMenuItems = buildDropDownMenuItems(userList);
                  });
                },
                child: Text("Add new Gerad to users")),
            TextButton(
                onPressed: () {
                  setState(() {
                    userList.clear();
                    nbSelectedUsers = 0;
                    userList.add(User("Gertrude", "https://loremflickr.com/500/500"));
                    _dropdownMenuItems = buildDropDownMenuItems(userList);
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
                  return Text("$name : $balance centimes", style: TextStyle(color : (balance == 0) ? Colors.white : (balance > 0) ? Colors.green : Colors.red));
                },
              ),
            ),
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
