import 'dart:ui';

import 'package:deed/Utils.dart';
import 'package:deed/classes/user.dart';
import 'package:deed/utils/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UserListDisplay extends StatelessWidget {
  final String group;

  UserListDisplay({this.group});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context);

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        semanticContainer: true,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.groupMembers,
                style: Theme.of(context).textTheme.headline2,
              ),
              Divider(),
              // ignore: non_constant_identifier_names
              FutureBuilder<List<IOUser>>(
                  future: getGroupUserList(group),
                  builder:
                      (BuildContext context, AsyncSnapshot<List<IOUser>> snap) {
                    if (snap.connectionState == ConnectionState.waiting)
                      return Loading();
                    List<IOUser> userList = snap.data;
                    return LimitedBox(
                      maxHeight: 300,
                      child: ListView.separated(

                        separatorBuilder: (BuildContext contex, int index) {
                          return Container(height: 8,);
                        },
                        shrinkWrap: true,
                          itemCount: userList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: CircleAvatar(
                                        radius: 18, backgroundImage: NetworkImage(userList[index].getUrl())),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(userList[index].getName()),
                                  )]);
                          }),
                    );
                  })
            ],
          ),
        ));
  }
}

void showUserListDisplay(BuildContext context, String group) {
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
                child: Wrap(
                  children: [
                    UserListDisplay(
                      group: group,
                    ),
                  ],
                )));
      });
}
