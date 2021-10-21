/// This file contains classes and/or functions that relate to the Tournament
/// Bracket. This is heart of this app. It contains the top app bar that allows
/// the user to increment/decrement rounds and change the playoff season, as
/// well as the interface that allows the user to manipulate the playoff graph.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/widgets/dropdown.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/utils.dart' as utils;
import 'package:tournament_app/widgets/tournament_bracket_node.dart';
import 'package:tournament_app/widgets/loading_screen.dart';
import 'package:tournament_app/styles.dart';

/// This widget is for the page with the NHL Tournament Bracket.
class TournamentBracket extends StatefulWidget {
  const TournamentBracket({Key? key}) : super(key: key);

  @override
  _TournamentBracketState createState() => _TournamentBracketState();
}

/// This is the private State class for the TournamentBracket.
class _TournamentBracketState extends State<TournamentBracket> {
  int currentRound = 5; // Set to 5 (i.e. playoffs over)
  Graph _graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration();
  late Future<List<PlayoffSeason>> _playoffsFuture;
  late List<PlayoffSeason> _playoffs;
  late PlayoffSeason _currentSeason;
  late TransformationController _controller;

  @override
  void initState() {
    super.initState();
    // Load playoff data
    _playoffsFuture = utils.loadAllPlayoffData().then((value) {
      _currentSeason = value.last;
      return value;
    });

    // Set up some graph options
    _builder
      ..siblingSeparation = (25)
      ..levelSeparation = (100) // controls separation between playoff rounds
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_RIGHT_LEFT);

    // Initialize controller for InteractiveViewer
    _controller = TransformationController();
    _controller.value = Matrix4.identity() * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlayoffSeason>>(
        future: _playoffsFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<PlayoffSeason>> snapshot) {
          if (snapshot.hasData) {
            _playoffs = snapshot.data!;
            _graph = utils.generatePlayoffGraph(_currentSeason);
            return Scaffold(
                appBar: buildTopAppBar(), body: buildInteractiveGraphViewer());
          } else if (snapshot.hasError) {
            return Scaffold(
                body: Center(child: Text("Error: ${snapshot.error}")));
          } else {
            return generateLoadingScreen();
          }
        });
  }

  /// Returns [AppBar] that appears at the top of the screen
  AppBar buildTopAppBar() {
    List<int> playoffYearNums = _playoffs.map((e) => e.seasonNum).toList();
    playoffYearNums.sort();
    return AppBar(
      backgroundColor: primaryColor,
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PlayoffYearDropdown(
              playoffYearNums: playoffYearNums,
              updateCurrentSeason: updateCurrentSeason,
            ),
            const SizedBox(width: 10),
            FloatingActionButton.extended(
              label: const Text("Prev\nRound", style: whiteTextStyle),
              onPressed: () {
                // Decrements round number if possible
                setState(() {
                  currentRound -= (currentRound >= 2) ? 1 : 0;
                });
              },
              backgroundColor: secondaryColor,
            ),
            SizedBox(
              child: Center(
                  child: Text(currentRound.toString(), style: whiteTextStyle)),
              width: 30.0,
            ),
            FloatingActionButton.extended(
              label: const Text("Next\nRound", style: whiteTextStyle),
              onPressed: () {
                // Increments round number if possible
                setState(() {
                  currentRound += (currentRound <= 4) ? 1 : 0;
                });
              },
              backgroundColor: secondaryColor,
            ),
          ]),
      centerTitle: true,
    );
  }

  /// Returns a [Container] that has the interface that allows the user to zoom,
  /// scroll, and browse through the playoff graph
  Container buildInteractiveGraphViewer() {
    return Container(
        margin: const EdgeInsets.all(0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(60.0),
                  minScale: 0.001,
                  maxScale: 1.0,
                  scaleEnabled: true,
                  transformationController: _controller,
                  child: GraphView(
                    graph: _graph,
                    algorithm: BuchheimWalkerAlgorithm(
                        _builder, TreeEdgeRenderer(_builder)),
                    paint: Paint()
                      ..color = Colors.green
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      PlayoffNode playoffNode = node as PlayoffNode;
                      playoffNode.currentRound = currentRound;
                      return generateTournamentBracketNode(
                          playoffNode, context);
                    },
                  )),
            ),
          ],
        ));
  }

  /// Updates current season to match provided seasonNum [int].
  /// Throws error if season couldn't be found or if playoffs list is empty.
  void updateCurrentSeason(int seasonNum) async {
    if (_playoffs.isEmpty) {
      throw Exception(
          "Couldn't update playoff season because our season list is empty");
    }
    setState(() {
      _currentSeason = _playoffs.firstWhere((s) => s.seasonNum == seasonNum,
          orElse: () => throw Exception(
              "Couldn't update playoff season as desired season not found"));
    });
  }
}
