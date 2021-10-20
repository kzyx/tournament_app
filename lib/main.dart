import 'package:flutter/material.dart';
import 'package:tournament_app/widgets/tournament_bracket.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: TournamentBracket(key: treeViewPageKey),
        theme: ThemeData(
          fontFamily: 'Urbanist',
        ),
      );
}
