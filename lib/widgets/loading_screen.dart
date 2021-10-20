import 'package:flutter/material.dart';

/// This widget shows a circular loading symbol in the center of the screen
Widget LoadingScreen() {
  return Scaffold(
      body: Container(
    margin: const EdgeInsets.all(50),
    child: Center(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
          SizedBox(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          ),
        ])),
  ));
}
