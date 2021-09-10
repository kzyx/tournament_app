import 'package:flutter/material.dart';
import 'package:tournament_app/treeviewpage_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: TreeViewPage(key: treeViewPageKey),
        theme: ThemeData(
          fontFamily: 'Urbanist',
        ),
      );
}
