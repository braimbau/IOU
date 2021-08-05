import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../Utils.dart';
import '../utils/error.dart';
import '../Routes/join_group.dart';

class GroupCreation extends StatefulWidget {
  final IOUser usr;

  GroupCreation({this.usr});

  @override
  _GroupCreationState createState() => _GroupCreationState();
}

class _GroupCreationState extends State<GroupCreation> {
  bool isCreated;
  String groupName;
  IOUser usr;
  String groupId;

  @override
  void initState() {
    isCreated = false;
    usr = this.widget.usr;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isCreated == false)
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
          child: SizedBox(
            width: 300,
            height: 150,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Create a new group",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              hintText: 'Group name',
                              fillColor: Colors.white,
                              filled: true),
                          onChanged: (String str) {
                            groupName = str;
                          }),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.east,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (groupName == null || groupName.length == 0){
                            WidgetsBinding.instance.focusManager.primaryFocus
                                ?.unfocus();
                            displayError("Chose a name to create a group", context);
                            return;
                          }
                          if (groupName.length > 10){
                            WidgetsBinding.instance.focusManager.primaryFocus
                                ?.unfocus();
                            displayError("The max length of the group name is 10 characters", context);
                            return;
                          }
                          groupId = await createGroup(groupName);
                          displayMessage(
                              'Group $groupName is created', context);
                          addGroup(groupId, usr.getId());
                          checkGroup(usr, groupId);
                          WidgetsBinding.instance.focusManager.primaryFocus
                              ?.unfocus();
                          setState(() {
                            isCreated = true;
                          });
                        }),
                  ],
                ),
              ),
            ]),
          ));
    else
      return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.blue,
          semanticContainer: true,
          elevation: 5,
          child: SizedBox(
            width: 300,
            height: 150,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            "Group $groupName created !",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isCreated = false;
                          });
                        })
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: IconButton(
                        icon: Icon(Icons.ios_share, color: Colors.white,),
                        onPressed: () async {
                          String url = await getGroupDynamicLink(groupId);
                          await Share.share(url);
                        }),
                  ),
                  VerticalDivider(
                    color: Colors.red,
                    thickness: 4,
                  ),
                  Column(
                    children: [
                      Text("group Id:", style: TextStyle(color: Colors.white60),),
                      SelectableText(groupId, style: TextStyle(color: Colors.white60),),
                    ],
                  )
                ],
              )
            ]),
          ));
  }
}
