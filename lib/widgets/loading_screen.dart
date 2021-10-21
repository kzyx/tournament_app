/// This class contains classes and/or functions relating to the full screen
/// circular loading widget that is shown while the tournament bracket loads.
import 'package:flutter/material.dart';

/// This widget shows a circular loading symbol in the center of the screen
Widget generateLoadingScreen() {
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
