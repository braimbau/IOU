import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/user.dart';
import 'package:deed/user_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget topAppBar(IOUser usr, String group){
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(children: [
        UserDisplay(usr: usr),
        Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(Icons.expand_more),
                  FutureBuilder<String>(future: getGroupNameById(group),
                      builder: (BuildContext context, AsyncSnapshot<String> groupName){
                    if (groupName.hasData)
                      return Text(groupName.data);
                    else
                      return Text("...");
                  })]
              ),
            )
        ),
        //Expanded(child: Image.asset('asset/image/logo.png', height: 45,)),
        Icon(Icons.settings, size: 40,),
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
      backgroundColor: Colors.grey[850],
    );
}

Future<String> getGroupNameById (String id) async {
  final DocumentReference document = FirebaseFirestore.instance.collection("groups").doc(id);
  var doc = await document.get();
  return doc["name"];
}