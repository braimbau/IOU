import 'dart:math';

import 'package:deed/utils/error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Logo extends StatefulWidget {
  @override
  _LogoState createState() => new _LogoState();
}

class _LogoState extends State<Logo>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  bool state;
  int speed = 1;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    state = false;
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: CircleBorder(
      ),
      onTap: () {
        if (state == false) {
          animationController.repeat();
        }
        else {
          animationController.stop();
        }
        state = !state;
      },
      child: new Container(
        alignment: Alignment.center,
        child: new AnimatedBuilder(
          animation: animationController,
          child: new Container(
            height: 45.0,
            width: 45.0,
            child: new Image.asset((Theme.of(context).brightness == Brightness.dark) ? 'asset/image/logo_dark.png' : 'asset/image/logo_light.png'),
          ),
          builder: (BuildContext context, Widget _widget) {
            return new Transform.rotate(
              angle: animationController.value * 2 * pi * speed,
              child: _widget,
            );
          },
        ),
      ),
    );
  }
}