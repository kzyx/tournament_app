import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/widgets/dropdown.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/utils.dart' as Utils;
import 'package:tournament_app/widgets/tournament_bracket_node.dart';
import 'package:tournament_app/widgets/loading_screen.dart';
import 'package:tournament_app/styles.dart';

// Key allows Dropdown widget to call method inside TreeViewPage.
// In some languages the use of global variables is frowned upon, so in the
// future it could be advisable to replace this.
GlobalKey<_TournamentBracketState> treeViewPageKey = GlobalKey();

/// This widget is for the page with the NHL Tournament Bracket
class TournamentBracket extends StatefulWidget {
  const TournamentBracket({Key? key}) : super(key: key);

  @override
  _TournamentBracketState createState() => _TournamentBracketState();
}

/// This is the private State class for the TournamentBracket page
class _TournamentBracketState extends State<TournamentBracket> {
  int currentRound = 5; // Set to 5 (i.e. playoffs over)
  Graph _graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration();
  late Future<List<PlayoffSeason>> _playoffsFuture;
  late List<PlayoffSeason> _playoffs;
  late PlayoffSeason _currentSeason;
  late TransformationController _controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlayoffSeason>>(
        future: _playoffsFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<PlayoffSeason>> snapshot) {
          if (snapshot.hasData) {
            _playoffs = snapshot.data!;
            _graph = Utils.generatePlayoffGraph(_currentSeason);
            return Scaffold(
                appBar: buildTopAppBar(),
                body: Container(
                    margin: const EdgeInsets.all(0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InteractiveViewer(
                              constrained: false,
                              boundaryMargin: EdgeInsets.all(60.0),
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
                                  return TournamentBracketNode(
                                      node as PlayoffNode,
                                      context,
                                      currentRound);
                                },
                              )),
                        ),
                      ],
                    )));
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Error: ${snapshot.error}")
              )
            );
          }
          else {
            return LoadingScreen();
          }
        });
  }

  AppBar buildTopAppBar() {
    return AppBar(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PlayoffsYearDropdown(
                  playoffsYearNums: Utils.getAllPlayoffYearNumbers(_playoffs)),
              SizedBox(width: 10),
              FloatingActionButton.extended(
                label: Text("Prev\nRound", style: whiteBoldText),
                onPressed: () {
                  // Decrements round number if possible
                  setState(() {
                    if (currentRound >= 2) {
                      currentRound -= 1;
                    }
                  });
                },
                backgroundColor: Colors.orange,
              ),
              Container(
                child: Center(
                    child: Text(currentRound.toString(), style: whiteBoldText)),
                width: 30.0,
              ),
              FloatingActionButton.extended(
                label: Text("Next\nRound", style: whiteBoldText),
                onPressed: () {
                  // Increments round number if possible
                  setState(() {
                    if (currentRound <= 4) {
                      currentRound += 1;
                    }
                  });
                },
                backgroundColor: Colors.orange,
              ),
            ]),
      ),
      centerTitle: true,
    );
  }

  @override
  void initState() {
    super.initState();
    // Load playoff data
    _playoffsFuture = Utils.loadAllPlayoffData().then((value) {
      _currentSeason = value.last;
      return value;
    });

    // Set up some graph options
    _builder
      ..siblingSeparation = (25)
      ..levelSeparation = (50)
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_RIGHT_LEFT);

    // Initialize controller for InteractiveViewer
    _controller = TransformationController();
    _controller.value = Matrix4.identity() * 0.8;
  }

  /// Updates current season to match provided seasonNum [int].
  /// Throws error if season
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
