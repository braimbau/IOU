import '../classes/InputInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AmountTextInput extends StatefulWidget {
  final void Function(InputInfo inputInfo) changeInputInfo;
  final bool isPreFilled;
  final int amount;
  final controller = TextEditingController();

  AmountTextInput({this.changeInputInfo, this.isPreFilled, this.amount}) {
    if (isPreFilled) controller.text = (amount / 100).toString();
  }

  @override
  _AmountTextInputState createState() => _AmountTextInputState();
}

class _AmountTextInputState extends State<AmountTextInput> {
  InputInfo inputInfo;

  @override
  void initState() {
    inputInfo = InputInfo(false, (this.widget.isPreFilled) ? this.widget.amount : 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    AppLocalizations t = AppLocalizations.of(context);

    return Stack(alignment: Alignment.center, children: [
      TextField(
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
          ),
          controller: this.widget.controller,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: t.enterAmount,
              filled: true),
          onChanged: (String str) {
            setState(() {
              double tmp;
              try {
                tmp = double.parse(str.replaceAll(',', '.')) * 100;
                inputInfo.setAmount(tmp.toInt());
                this.widget.changeInputInfo(inputInfo);
              } on Exception catch (_) {
                inputInfo.setAmount(-1);
                this.widget.changeInputInfo(inputInfo);
              }
            });
          }),
      Positioned(
        child: InkWell(
          onTap: () {
            setState(() {
              inputInfo.toggleIndividual();
              this.widget.changeInputInfo(inputInfo);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.euro),
                if (inputInfo.getIsIndividual())
                  Text("/", style: TextStyle(fontSize: 20)),
                if (inputInfo.getIsIndividual()) Icon(Icons.person)
              ],
            ),
          ),
        ),
        right: 0,
      )
    ]);
  }
}
