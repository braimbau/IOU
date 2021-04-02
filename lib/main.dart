import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Home()
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('IOU'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget> [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child : FlatButton(
                    onPressed: (){
                      setState(() {
                        count += 1;
                      });
                    },
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                      color: Colors.amber,
                    child: Text('Adrien'
                        '\n$count',),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: (){
                      setState(() {
                      count += 1;
                      });
                      },
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                      color: Colors.blue,
                      child: Text('Billy\n$count'),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: (){
                        setState(() {
                          count += 1;
                        });
                      },
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                      color: Colors.red,
                      child:  Text('Jules\n$count'),
                    ),
                  ),
                ),
              ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget> [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child : FlatButton(
                    onPressed: (){},
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    color: Colors.white,
                    child: Text('Steven',),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: (){},
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    color: Colors.cyan,
                    child: Text('Samuel'),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: (){},
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    color: Colors.deepOrange,
                    child:  Text('Sarah'),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget> [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child : FlatButton(
                    onPressed: (){},
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    color: Colors.amber,
                    child: Text('Arthur',),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: (){},
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    color: Colors.blue,
                    child: Text('Fabrizio'),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: (){},
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                    color: Colors.red,
                    child:  Text('Leo',),
                ),
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


//