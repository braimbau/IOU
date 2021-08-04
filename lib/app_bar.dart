import 'package:cloud_firestore/cloud_firestore.dart';
import 'error.dart';
import 'group_picker.dart';
import 'user.dart';
import 'user_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget topAppBar(IOUser usr, String group, BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        UserDisplay(usr: usr, group: group),
        InkWell(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          onTap: () {
            print("bite");
            showGroupPicker(context, usr, group);
          },
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(children: [
                  Icon(Icons.expand_more
                  ),
                  FutureBuilder<String>(
                      future: getGroupNameById(group),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> groupName) {
                        if (groupName.hasData)
                          return Text(groupName.data, style: TextStyle(fontSize: 25),);
                        else
                          return Text("...");
                      })
                ]),
              )),
        ),
        //Expanded(child: Image.asset('asset/image/logo.png', height: 45,)),
        Icon(
          Icons.settings,
          size: 40,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    ),
    backgroundColor: Colors.grey[850],
  );
}

Future<String> getGroupNameById(String id) async {
  final DocumentReference document =
      FirebaseFirestore.instance.collection("groups").doc(id);
  var doc = await document.get();
  return doc["name"];
}

void showGroupPicker(BuildContext context, IOUser usr, String group) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext contextOfDialog) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GroupPickerCard(
                  usr: usr,
                  excludeGroup: group,
                )
              ]),
        ],
      );
    },
  );
}

