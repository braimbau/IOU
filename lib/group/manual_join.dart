import 'dart:ui';

import 'package:deed/Routes/join_group.dart';
import 'package:deed/classes/user.dart';
import 'package:deed/utils/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Utils.dart';

class ManualJoin extends StatelessWidget {
  final BuildContext context;
  final IOUser usr;

  ManualJoin({this.context, this.usr});

  @override
  Widget build(BuildContext context) {
    TextEditingController ctrl = TextEditingController();
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
        child: SizedBox(
          width: 100,
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
                IconButton(icon: Icon(Icons.paste, color: Colors.white,), onPressed: () async {
                  ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
                  groupId = data.text;
                  ctrl.text = data.text;
                }),
                Flexible(
                  child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: ctrl,
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
                      print(groupId);
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
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
                      displayMessage(
                          "You've successfully join this group", context);
                    }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.info_outline, color: Colors.white54,),
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(
                        "You can get the group Id by long pressing the group pill",
                        style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

void showManualJoin(BuildContext context, IOUser usr) {
  showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: ManualJoin(
                  context: context,
                  usr: usr,
                )));
      });
}
