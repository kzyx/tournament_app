/// This file contains classes and/or functions that relate to the running
/// of the main app.
import 'package:flutter/material.dart';
import 'package:tournament_app/widgets/tournament_bracket.dart';
import 'package:tournament_app/styles.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: TournamentBracket(key: tournamentBracketKey),
        theme: ThemeData(
          fontFamily: defaultFont,
        ),
      );
}
