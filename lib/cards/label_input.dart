import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LabelTextInput extends StatefulWidget {
  final bool isPreFilled;
  final String label;
  final void Function(String value) changeLabel;
  final controller = TextEditingController();

  LabelTextInput({this.isPreFilled, this.label, this.changeLabel}) {
    if (isPreFilled)
      controller.text = label;
  }
  @override
  _LabelTextInputState createState() => _LabelTextInputState();
}

class _LabelTextInputState extends State<LabelTextInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: this.widget.controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: '(optional) Label',
            filled: true),
        onChanged: (String str) {
          setState(() {
            this.widget.changeLabel(str);
          });
        });
  }
}