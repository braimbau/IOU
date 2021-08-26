import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/utils/loading.dart';
import 'amount_card.dart';
import 'pref_picker.dart';
import '../classes/quick_pref.dart';
import '../classes/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class QuickCard extends StatelessWidget {
  final IOUser usr;
  final String group;

  QuickCard({this.usr, this.group});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context);

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .doc(group)
            .collection("quickadds")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(t.err1);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          List<QuickPref> quickPrefList = List<QuickPref>.empty(growable: true);
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            quickPrefList.add(QuickPref(
                snapshot.data.docs[i]["name"],
                snapshot.data.docs[i]["users"],
                snapshot.data.docs[i]["amount"],
                snapshot.data.docs[i]["emoji"],
                snapshot.data.docs[i].id));
          }
          return new Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // if you need this
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            semanticContainer: true,
            elevation: 5,
            child: Column(
              children: [
                Padding(
                    child: Text(t.quickAdds,
                        style: Theme.of(context).textTheme.headline3),
                    padding: EdgeInsets.all(8)),
                SizedBox(
                  height: 90,
                  child: Row(
                    children: [
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: quickPrefList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return TextButton(
                              child: Text(
                                quickPrefList[index].getEmoji(),
                                style: TextStyle(fontSize: 50),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _buildPopupDialog(context, usr,
                                          quickPrefList[index], group),
                                );
                              },
                              onLongPress: () {
                                _confirmQuickDelete(
                                    context, quickPrefList[index], group);
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                          child: IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 30,
                                color: Colors.blue,
                              ),
                              splashRadius: 25,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _buildPrefPicker(group),
                                );
                              }),
                          padding: EdgeInsets.only(top: 15))
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

Future<void> _confirmQuickDelete(
    BuildContext context, QuickPref pref, String group) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      AppLocalizations t = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(t.delete + " " + pref.getName()),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(t.confirmDeleteQuickAdd),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(t.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(t.delete),
            onPressed: () {
              removeQuickPref(group, pref.getId());
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> removeQuickPref(String groupId, String id) async {
  CollectionReference ref = FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection("quickadds");
  ref.doc(id).delete();
}

Widget _buildPopupDialog(
    BuildContext context, IOUser usr, QuickPref pref, String group) {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Wrap(children: <Widget>[
            AmountCard(
                currentUserId: usr.getId(),
                isPreFilled: true,
                pref: pref,
                group: group)
          ])));
}

Widget _buildPrefPicker(String group) {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Wrap(children: <Widget>[
            PrefPicker(
              group: group,
            )
          ])));
}
