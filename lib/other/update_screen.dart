import 'package:deed/utils/logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Logo(),
        Text("Please update the app to continue using IOU", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
        ElevatedButton(onPressed: () {
          Navigator.of(context).pushReplacementNamed('/');
        }, child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.replay),
            Text('Retry'),
          ],
        )),
      ],),
    );
  }
}
