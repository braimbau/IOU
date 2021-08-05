import 'package:cloud_firestore/cloud_firestore.dart';
import 'Utils.dart';
import 'join_group.dart';
import 'user.dart';
import 'package:flutter/cupertino.dart';

import 'loading.dart';

class GroupScreen extends StatelessWidget {
  final IOUser usr;
  final String groupInvite;

  GroupScreen({this.usr, this.groupInvite});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getDefaultGroups(usr.getId()),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          if (snapshot.data == "" || snapshot.data == null || snapshot.hasError)
            return JoinGroup(usr: usr, groupInvite: groupInvite, defaultGroup: null,);
          else
            return JoinGroup(usr: usr, groupInvite: groupInvite, defaultGroup: snapshot.data,);

          return Container();
        });
  }

}