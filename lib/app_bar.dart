import 'package:deed/user.dart';
import 'package:deed/user_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget topAppBar(IOUser usr){
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(children: [
        UserDisplay(usr: usr),
        Expanded(child: Image.asset('asset/image/logo.png', height: 45,)),
        Icon(Icons.settings, size: 40,),
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
      backgroundColor: Colors.grey[850],
    );
}