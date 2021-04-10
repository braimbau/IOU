import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int balance = 0;
  int amountToPay = 0;
  Color c = Colors.amber;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [Text("$balance")],
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                      ClipOval(
                        child : Material(
                          color : c,
                        child: InkWell(
                          splashColor: Colors.red, // inkwell color
                          child: SizedBox(width: 56, height: 56, child: Icon(Icons.people)),
                          onTap:(
                              ) {
                            setState(() {
                              c = Colors.red;
                            });
                          },

                        ),
                      ),
                      ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),)
      ,
    );
  }
}

//
