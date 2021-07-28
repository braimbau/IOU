import 'user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectionWidget extends StatefulWidget {
  final IOUser user;
  final List<IOUser> userSelected;
  final void Function(IOUser usr) addUserToSelected;
  final void Function(IOUser usr) rmUserToSelected;

  SelectionWidget({this.user, this.addUserToSelected, this.rmUserToSelected, this.userSelected});
  @override
  _SelectionWidgetState createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  bool isSelected;

  @override
  Widget build(BuildContext context) {
    isSelected = this.widget.userSelected.contains(this.widget.user);
    return InkWell(
        customBorder: CircleBorder(),
        onTap: () {
          setState(() {
            this.isSelected = !this.isSelected;
            if (isSelected)
              this.widget.addUserToSelected(this.widget.user);
            else {
              this.widget.rmUserToSelected(this.widget.user);
            }
          });
        },
        child: CircleAvatar(
            radius: 25,
            backgroundColor: (this.isSelected) ? Colors.blue : Colors.white,
            child: CircleAvatar(radius: 22,  backgroundImage: NetworkImage(this.widget.user.getUrl()))
        )
    );
  }
}