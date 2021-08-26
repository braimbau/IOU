import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/utils/error_screen.dart';
import 'package:deed/utils/loading.dart';
import 'label_input.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../classes/InputInfo.dart';
import 'amount_input.dart';
import '../classes/user.dart';
import 'selection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PrefPicker extends StatelessWidget {
  final String group;

  PrefPicker({this.group});

  @override
  Widget build(BuildContext context) {
    AppLocalizations tr = AppLocalizations.of(context);

    ValueNotifier<int> amountToPayPerUser = ValueNotifier(0);
    List<IOUser> selectedUsers = [];
    ValueNotifier<String> emoji = ValueNotifier("");
    ValueNotifier<int> amountToPay = ValueNotifier(0);
    ValueNotifier<String> secondaryDisplay = ValueNotifier("");
    InputInfo inputInfo = InputInfo(false, 0);

    String label = tr.unnamedQuickPref;

    void updateAmountToPay() {
      if (inputInfo.getIsIndividual() == false) {
        amountToPay.value = inputInfo.getAmount();
        if (selectedUsers.length == 0) {
          amountToPayPerUser.value = -1;
          secondaryDisplay.value = "";
        } else {
          amountToPayPerUser.value = amountToPay.value ~/ selectedUsers.length;
          double dAmount = amountToPayPerUser.value / 100;
          secondaryDisplay.value =  (amountToPayPerUser.value > 0) ? tr.usersOwe + dAmount.toString() : "";
        }
      } else {
        amountToPayPerUser.value = inputInfo.getAmount();
        amountToPay.value = amountToPayPerUser.value * selectedUsers.length;
        double dAmount = amountToPay.value / 100;
        secondaryDisplay.value =  (amountToPay.value > 0) ? tr.totalAmount + dAmount.toString() : "";
      }
    }

    void changeInputInfo(InputInfo ii) {
      inputInfo = ii;
      updateAmountToPay();
    }

    void changeLabel(String value) {
      label = value;
    }

    void addUserToSelected(IOUser usr) {
      selectedUsers.add(usr);
      updateAmountToPay();
    }

    void rmUserToSelected(IOUser usr) {
      selectedUsers.remove(usr);
      updateAmountToPay();
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("groups").doc(group).collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorScreen(tr.err1);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (snapshot.data.docs.length == 0) return Text(tr.noUsers);

        List<IOUser> userList = List<IOUser>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          userList.add(IOUser(snapshot.data.docs[i]["id"],
              snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }

        selectedUsers.removeWhere((element) => !userList.contains(element));
        return new Card(
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
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: AmountTextInput(
                        changeInputInfo: changeInputInfo,
                        isPreFilled: false,
                        amount: 0,
                      ),
                    ),
                    SizedBox(
                      child: IconButton(
                          icon: const Icon(Icons.east),
                          onPressed: () async {
                            onValidation(
                                amountToPay,
                                selectedUsers,
                                emoji.value,
                                context,
                                label,
                                group,
                            inputInfo.getIsIndividual());
                          }),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: secondaryDisplay,
                        builder:
                            (BuildContext context, String text, Widget child) {
                          return Visibility(
                            visible: (text != null && text != ""),
                            child: Text(text, style: Theme.of(context).textTheme.bodyText1,),
                          );
                        })
                  ],
                ),
                SizedBox(
                  height: 65,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.docs.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        width: 4,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return SelectionWidget(
                          user: userList[index],
                          addUserToSelected: addUserToSelected,
                          rmUserToSelected: rmUserToSelected,
                          userSelected: selectedUsers);
                    },
                  ),
                ),
                Row(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: emoji,
                        builder:
                            (BuildContext context, String emoji, Widget child) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (emoji == "") ? Image.asset('asset/image/emojis.png', height: 45,)
                            : Text(
                              (emoji == "") ? "🙂" : emoji,
                              style: TextStyle(fontSize: 40),
                            ),
                          );
                        }),
                    Expanded(
                      child: LabelTextInput(
                          isPreFilled: false,
                          label: null,
                          changeLabel: changeLabel),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.transparent,
                  height: 4,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FittedBox(
                      child: EmojiPicker(
                        bgColor: Theme.of(context).backgroundColor,
                    rows: 4,
                    selectedCategory: Category.FOODS,
                    columns: 8,
                    buttonMode: ButtonMode.CUPERTINO,
                    numRecommended: 10,
                    onEmojiSelected: (emojiSelected, category) {
                      emoji.value = emojiSelected.emoji;
                    },
                  )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

String amountError(int amount, int nbUsers, String emoji, AppLocalizations t) {
  if (emoji == null || emoji == "") return (t.amountError5);
  if (nbUsers == 0) return (t.amountError1);
  if (amount <= 0) return (t.amountError2);
  if (amount ~/ nbUsers == 0) return (t.amountError3);
  if (amount > 100000000) return (t.amountError4);
  return null;
}

Future<void> addQuickPref(String groupId, String label, String users,
    int amount, String emoji, bool isIndividual) async {
  var docRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection("quickadds")
      .doc();
  docRef.set({'name': label, 'amount': amount, 'users': users, 'emoji': emoji, 'isIndividual': isIndividual});
}

Future<void> onValidation(
    ValueNotifier<int> amountToPay,
    List<IOUser> selectedUsers,
    String emoji,
    BuildContext context,
    String label,
    String groupId, bool isIndividual) {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  AppLocalizations t = AppLocalizations.of(context);
  String err = amountError(amountToPay.value, selectedUsers.length, emoji, t);
  if (err != null) {
    Flushbar(
      message: err,
      backgroundColor: Colors.red,
      borderRadius: BorderRadius.all(Radius.circular(50)),
      icon: Icon(
        Icons.error_outline,
        size: 28,
        color: Colors.white,
      ),
      duration: Duration(seconds: 2),
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    )..show(context);
  } else {
    addQuickPref(
        groupId, label, selectedUsers.join(":"), amountToPay.value, emoji, isIndividual);
    //pop until main page to avoid poping only flushbar
    Navigator.of(context).popUntil(ModalRoute.withName('/mainPage'));
    Flushbar(
      message: t.quickAdd + label + t.isRegistered,
      backgroundColor: Colors.green,
      borderRadius: BorderRadius.all(Radius.circular(50)),
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.white,
      ),
      duration: Duration(seconds: 2),
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    )..show(context);
  }
}
