import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deed/user.dart';
import 'package:flutter/material.dart';

class PayerWidget extends StatefulWidget {
  final List<IOUser> userList;
  final List<DropdownMenuItem<IOUser>> dropdownMenuItems;
  final IOUser firstSelected;
  final void Function(IOUser usr) setPayer;

  PayerWidget({this.userList, this.dropdownMenuItems, this.firstSelected, this.setPayer});
  @override
  _PayerWidgetState createState() => _PayerWidgetState();
}

class _PayerWidgetState extends State<PayerWidget> {
  IOUser  selectedItem;

  @override
  Widget build(BuildContext context) {
    if (!this.widget.userList.contains(selectedItem)) {
      selectedItem = this.widget.firstSelected;
      this.widget.setPayer(selectedItem);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: DropdownButton<IOUser>(
          value: selectedItem,
          items: this.widget.dropdownMenuItems,
          selectedItemBuilder: (_) {
            return this.widget.userList
                .map((e) => Container(
              width: 170,
              alignment: Alignment.centerLeft,
              child: Text(selectedItem.getName(),
                style: TextStyle(color: Colors.white),
              ),
            ))
                .toList();
          },
          onChanged: (value) {
            setState(() {
              selectedItem = value;
              this.widget.setPayer(selectedItem);
            });
          }),
    );
  }
}

class PayerDropDown extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        if (snapshot.data.docs.length == 0)
          return Text("No users to display");

        List<IOUser> userList = List<IOUser>.empty(growable: true);
        for (int i = 0; i < snapshot.data.docs.length; i++){
          userList.add(IOUser(snapshot.data.docs[i]["id"], snapshot.data.docs[i]["name"], snapshot.data.docs[i]["url"]));
        }
        List<DropdownMenuItem<IOUser>> dropdownMenuItems = buildDropDownMenuItems(userList);

        return new PayerWidget(userList: userList, dropdownMenuItems: dropdownMenuItems);
      },
    );
  }
}

List<DropdownMenuItem<IOUser>> buildDropDownMenuItems(List listItems) {
  List<DropdownMenuItem<IOUser>> items = [];
  for (IOUser listItem in listItems) {
    items.add(
      DropdownMenuItem(
        child: Row(
            children:<Widget>[
              CircleAvatar(
                radius: 15,
                backgroundImage:
                NetworkImage(listItem.getUrl()),
              ),
              Text(listItem.getName(),
                  style : TextStyle(color: Colors.black,))
            ]),
        value: listItem,
      ),
    );
  }
  return items;
}