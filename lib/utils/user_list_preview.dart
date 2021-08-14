import 'package:deed/balance/balancing.dart';
import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserListPreview extends StatelessWidget {
  final List<IOUser> list;
  final int maxLength;

  UserListPreview({this.list, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: ListView.builder(
          itemCount: (list.length > maxLength) ? maxLength : list.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
                width: 20,
                child: OverflowBox(
                  maxWidth: 30,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: CircleAvatar(
                        radius: 13,
                        backgroundImage: NetworkImage((index ==
                            maxLength - 1)
                            ? 'https://firebasestorage.googleapis.com/v0/b/iou-71bca.appspot.com/o/Plus.png?alt=media&token=3011e516-1ebb-438f-bd51-fecc40c5f78d'
                            : list[index].getUrl())),
                  ),
                ));
          },
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
        ),
      ),
    );
  }
}

class BalanceUserListPreview extends StatelessWidget {
  final List<UserBalance> list;
  final int maxLength;

  BalanceUserListPreview({this.list, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: ListView.builder(
          itemCount: (list.length > maxLength) ? maxLength : list.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
                width: 20,
                child: OverflowBox(
                  maxWidth: 30,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: CircleAvatar(
                        radius: 13,
                        backgroundImage: NetworkImage((index ==
                                maxLength - 1)
                            ? 'https://firebasestorage.googleapis.com/v0/b/iou-71bca.appspot.com/o/Plus.png?alt=media&token=3011e516-1ebb-438f-bd51-fecc40c5f78d'
                            : list[index].getUrl())),
                  ),
                ));
          },
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
        ),
      ),
    );
  }
}
