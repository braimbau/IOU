import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void displayError(String err, BuildContext context)
{
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
}

void displayMessage(String msg, BuildContext context)
{
  Flushbar(
    message: msg,
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