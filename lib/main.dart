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
  Color _color;
  bool _isSelected;
  String _url;

  User(String name, String url) {
    this._name = name;
    this._url = url;
    this._isSelected = false;
  }

  addBalance(int n) {
    _balance += n;
  }
}

class _HomeState extends State<Home> {
  int balance = -1;
  double dbalance;
  int amountToPay = 0;
  final myController = TextEditingController();
  List<User> userList = List<User>.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    //initialise user list

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('IOU'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              semanticContainer: true,
              elevation: 5,
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                            signed: false,
                            decimal: true,
                          ),
                          controller: myController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter the amount to pay'),
                          onChanged: (String str) {setState(() {
                            double tmp;
                            try {
                              tmp = double.parse(
                                  myController.text.replaceAll(',', '.')) *
                                  100;
                            }
                            on Exception catch (_) {
                              tmp = -2;
                            }
                            balance = tmp.toInt();
                            num nbSelected = 0;
                            userList.forEach((User user) {
                              if (user._isSelected) nbSelected++;
                            });
                            if (nbSelected == 0)
                              balance = -1;
                            else
                              balance = balance ~/ nbSelected;
                            dbalance = balance / 100;
                          });},
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.trending_up),
                          onPressed: () {
                            setState(() {
                              double tmp = double.parse(
                                      myController.text.replaceAll(',', '.')) *
                                  100;

                              balance = tmp.toInt();
                              num nbSelected = 0;
                              userList.forEach((User user) {
                                if (user._isSelected) nbSelected++;
                              });
                              if (nbSelected == 0)
                                balance = -1;
                              else
                                balance = balance ~/ nbSelected;
                              dbalance = balance / 100;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text((balance > 0)
                          ? "Each people owe $dbalance euros"
                          : (dbalance == -1) ? "please select user(s)" : "Enter an amount")
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
                                double tmp;
                                userList[index]._isSelected = !userList[index]._isSelected;
                                try {
                                  tmp = double.parse(
                                      myController.text.replaceAll(',', '.')) *
                                      100;
                                }
                                on Exception catch (_) {
                                  tmp = -2;
                                }
                                balance = tmp.toInt();
                                num nbSelected = 0;
                                userList.forEach((User user) {
                                  if (user._isSelected) nbSelected++;
                                });
                                if (nbSelected == 0)
                                  balance = -1;
                                else
                                  balance = balance ~/ nbSelected;
                                dbalance = balance / 100;
                              });
                            },
                            child: CircleAvatar(
                                radius: 25,
                                backgroundColor: (userList[index]._isSelected) ? Colors.red : Colors.grey,
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
                  });
                },
                child: Text("Do a Geranocide"))
          ],
        ),
      ),
    );
  }
}
