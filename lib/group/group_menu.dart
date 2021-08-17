import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/classes/group.dart';
import 'package:deed/classes/user.dart';
import 'package:deed/history/history_group.dart';
import 'package:deed/other/user_list_display.dart';
import 'package:deed/routes/main_page.dart';
import 'package:deed/utils/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

import '../Utils.dart';
import 'group_picker.dart';

class GroupMenu extends StatefulWidget {
  final IOUser usr;
  final String excludeGroup;
  final List<Group> groupList;

  GroupMenu({this.usr, this.excludeGroup, this.groupList});

  @override
  _GroupMenuState createState() => _GroupMenuState();
}

class _GroupMenuState extends State<GroupMenu> {
  IOUser usr;
  String group;
  List<Group> groupList;
  //bool isEditable = false;
  //TextEditingController ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    usr = this.widget.usr;
    group = this.widget.excludeGroup;
    groupList = this.widget.groupList;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: SizedBox(
        width: 185,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 30,
                child: FittedBox(
                  child: Text(
                    groupList
                        .firstWhere((element) => element.getId() == group)
                        .getName(),
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.ios_share,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        String groupName = await getGroupNameById(group);
                        String url =
                            await getGroupDynamicLink(group, groupName);
                        await Share.share(url);
                      }),
                  IconButton(
                    onPressed: (){
                      showUserListDisplay(context, group);
                    },
                    icon: Icon(
                      Icons.people,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => HistoryGroup(usr: usr, group: group,),
                      );
                    },
                    icon: Icon(
                      Icons.list,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FavGroup(usrId: usr.getId(), group: group),
                  ElevatedButton(
                    onPressed: () {
                      confirmLeaveGroup(context, usr.getId(), group);
                    },
                    child: Text(
                      'Leave group',
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(), primary: Colors.red),
                  ),
                ],
              ),
              if (groupList.isNotEmpty) Divider(),
              GroupPicker(
                usr: usr,
                excludeGroup: this.widget.excludeGroup,
                groupList: groupList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavGroup extends StatelessWidget {
  final String usrId;
  final String group;

  FavGroup({this.usrId, this.group});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(usrId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) return Container();
          return IconButton(
              icon: Icon(
                (snapshot.data["defaultGroup"] == group)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                await toggleDefaultGroup(usrId, group);
              });
        });
  }
}

confirmLeaveGroup(BuildContext context, String usrId, String group) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Leave group'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Are you sure you want to leave this group ?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Leave'),
            onPressed: () async {
              String err = await leaveGroup(usrId, group);
              Navigator.of(context).popUntil(ModalRoute.withName('/mainPage'));
              if (err != null)
                displayError(err, context);
              else
                Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
