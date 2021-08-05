import 'package:deed/Routes/join_group.dart';
import 'package:deed/classes/user.dart';
import 'package:deed/utils/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils.dart';

class ManualJoin extends StatelessWidget {
  final BuildContext context;
  final IOUser usr;

  ManualJoin({this.context, this.usr});

  @override
  Widget build(BuildContext context) {
    String groupId;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.grey[900],
      semanticContainer: true,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.build_outlined, color: Colors.white),
              ),
              Text(
                "Manual join",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                child: TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Group code',
                        fillColor: Colors.white,
                        filled: true),
                    onChanged: (String str) {
                      groupId = str;
                    }),
              ),
              IconButton(
                  icon: Icon(
                    Icons.east,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                    if (!await groupExist(groupId)) {
                      Navigator.of(context).popUntil(ModalRoute.withName('/'));
                      displayError("Invalid code", context);
                      return;
                    }
                    if (await userIsInGroup(groupId, usr.getId())) {
                      Navigator.of(context).popUntil(ModalRoute.withName('/'));
                      displayError("You're already in that group", context);
                      return;
                    }
                    addGroup(groupId, usr.getId());
                    checkGroup(usr, groupId);
                    Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    displayMessage("You've successfully join this group", context);
                  }),
            ],
          ),
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("You can get the group Id by long pressing the group pill", style: TextStyle(color: Colors.white54)),
            ),
          ),
        ]),
      ),
    );
  }
}

void showManualJoin(BuildContext context, IOUser usr) {
  showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: ManualJoin(
            context: context,
            usr: usr,
          ),
        );
      });
}
