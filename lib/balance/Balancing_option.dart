import 'dart:ui';

import 'package:deed/classes/user.dart';
import 'package:deed/utils/user_list_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'balancing.dart';
import 'balancing_transaction.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    AppLocalizations t = AppLocalizations.of(context);

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
                        t.bestOption,
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
                            ? t.refund + balancing.length.toString() + t.peoples
                            : t.get + balancing.length.toString() + t.refunds),
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

    AppLocalizations t = AppLocalizations.of(context);

    return Row(
      children: [
        BalanceUserListPreview(list: list, maxLength: 5,),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            children: [
              Text((list.first.getBalance() > 0)
                  ? t.refund + list.length.toString() + t.peoples
                  : t.get + list.length.toString() + t.refunds),
            ],
          ),
        )
      ],
    );
  }
}
