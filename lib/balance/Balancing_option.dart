import 'dart:ui';

import 'package:deed/classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'balancing.dart';
import 'balancing_transaction.dart';

class BalancingOptionCard extends StatefulWidget {
  final List<UserBalance> balancing;
  final bool isBest;
  final bool isDeployed;
  final void Function() resetPicked;
  final String group;
  final IOUser usr;
  final Function(String groupId, String usrId) updateBalancingOptions;

  BalancingOptionCard(
      {this.balancing,
      this.isBest,
      this.isDeployed,
      this.resetPicked,
      this.group,
      this.usr,
      this.updateBalancingOptions});

  @override
  _BalancingOptionCardState createState() => _BalancingOptionCardState();
}

class _BalancingOptionCardState extends State<BalancingOptionCard> {
  @override
  Widget build(BuildContext context) {
    List<UserBalance> balancing = this.widget.balancing;
    bool isBest = this.widget.isBest;
    bool isDeployed = this.widget.isDeployed;
    print(isDeployed);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      semanticContainer: true,
      elevation: 5,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Visibility(
              visible: isBest && isDeployed == false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  color: Colors.blue,
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.white),
                      Text(
                        "BEST OPTION",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isDeployed == false,
              child: BalancingOptionPreview(
                list: balancing,
              ),
            ),
            Visibility(
                visible: isDeployed == true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 20,
                        ),
                        Text((balancing.first.getBalance() > 0)
                            ? "Refund ${balancing.length} people"
                            : "Get ${balancing.length} refunds"),
                        InkWell(
                            customBorder: CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.close),
                            ),
                            onTap: () {
                              this.widget.updateBalancingOptions(this.widget.group, this.widget.usr.getId());
                              this.widget.resetPicked();
                            }),
                      ],
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider();
                        },
                        itemCount: balancing.length,
                        itemBuilder: (BuildContext context, int index) {
                          return BalancingTransaction(
                            transaction: balancing[index],
                            group: this.widget.group,
                            usr: this.widget.usr,
                          );
                        })
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class BalancingOptionPreview extends StatelessWidget {
  final List<UserBalance> list;

  BalancingOptionPreview({this.list});

  @override
  Widget build(BuildContext context) {
    if (list.length > 5) {
      list[4].setUrl(
          "https://firebasestorage.googleapis.com/v0/b/iou-71bca.appspot.com/o/InvitationPreview.png?alt=media&token=6ed44008-7fcd-4a4e-9bd0-18462da18bda");
      list.removeRange(5, list.length - 1);
    }
    return Row(
      children: [
        SizedBox(
          height: 30,
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ListView.builder(
              itemCount: list.length,
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
                            backgroundImage:
                                NetworkImage(list[index].getUrl())),
                      ),
                    ));
              },
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            children: [
              Text((list.first.getBalance() > 0)
                  ? "Refund ${list.length} people"
                  : "Get ${list.length} refunds"),
            ],
          ),
        )
      ],
    );
  }
}
