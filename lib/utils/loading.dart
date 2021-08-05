import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => new _LoadingState();
}

class _LoadingState extends State<Loading>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );

    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: new AnimatedBuilder(
        animation: animationController,
        child: new Container(
          height: 150.0,
          width: 150.0,
          child: new Image.asset('asset/image/logo.png'),
        ),
        builder: (BuildContext context, Widget _widget) {
          return new Transform.rotate(
            angle: animationController.value * 100,
            child: _widget,
          );
        },
      ),
    );
  }
}