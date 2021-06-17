import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AmountTextInput extends StatefulWidget {
  final void Function(int value) changeATP;
  final bool isPreFilled;
  final int amount;
  final controller = TextEditingController();

  AmountTextInput({this.changeATP, this.isPreFilled, this.amount}) {
    if (isPreFilled)
      controller.text = (amount / 100).toString();
  }
  @override
  _AmountTextInputState createState() => _AmountTextInputState();
}

class _AmountTextInputState extends State<AmountTextInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        style: TextStyle(color : Colors.black),
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
        ),
        controller: this.widget.controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter the amount to pay',
            fillColor: Colors.white70,
            filled: true),
        onChanged: (String str) {
          setState(() {
            double tmp;
            try {
              tmp = double.parse(str.replaceAll(',', '.')) * 100;
              this.widget.changeATP(tmp.toInt());
            }
            on Exception catch (_) {
              this.widget.changeATP(-1);
              return;
            }
            this.widget.changeATP(tmp.toInt());
          });
        });
  }
}