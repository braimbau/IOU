import 'package:deed/utils/logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Logo(),
        Text(t.updateApp, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
        ElevatedButton(onPressed: () {
          Navigator.of(context).pushReplacementNamed('/');
        }, child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.replay),
            Text(t.retry),
          ],
        )),
      ],),
    );
  }
}
