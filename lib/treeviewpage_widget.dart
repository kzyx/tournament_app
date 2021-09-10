import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/dropdown_widget.dart';
import 'package:tournament_app/models.dart';
import 'package:tournament_app/utils.dart' as Utils;

// Key allows Dropdown widget to call method inside TreeViewPage.
// In some languages the use of global variables is frowned upon, so in the
// future it could be advisable to replace this.
GlobalKey<_TreeViewPageState> treeViewPageKey = GlobalKey();

// Some default text styles
const TextStyle whiteBoldText =
    TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white);
const TextStyle blackBoldText =
    TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black);

/// This widget is for the page with the tree view playoff bracket
class TreeViewPage extends StatefulWidget {
  const TreeViewPage({Key? key}) : super(key: key);

  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

/// This is the private State class for the TreeViewPage
class _TreeViewPageState extends State<TreeViewPage> {
  late Playoffs _playoffs;
  int currentRound = 3; // Set to three by default as per instructions
  bool finishedLoading = false;
  Graph _graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  Widget build(BuildContext context) {
    if (!finishedLoading) {
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
    } else {
      return Scaffold(
          body: Container(
              margin: const EdgeInsets.only(top: 90.0, bottom: 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          const PlayoffsYearDropdown(),
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
                            // child: const Text("Remove"),
                            backgroundColor: Colors.orange,
                          ),
                          Text(currentRound.toString(), style: blackBoldText),
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
                        ],
                      )
                    ],
                  ),
                  Expanded(
                    child: InteractiveViewer(
                        constrained: false,
                        boundaryMargin: EdgeInsets.all(50.0),
                        minScale: 0.8,
                        maxScale: 0.8,
                        scaleEnabled: false,
                        child: GraphView(
                          graph: _graph,
                          algorithm: BuchheimWalkerAlgorithm(
                              builder, TreeEdgeRenderer(builder)),
                          paint: Paint()
                            ..color = Colors.green
                            ..strokeWidth = 1
                            ..style = PaintingStyle.stroke,
                          builder: (Node node) {
                            return rectangleWidget(node as PlayoffNode);
                          },
                        )),
                  ),
                ],
              )));
    }
  }

  Widget rectangleWidget(PlayoffNode playoffNode) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: AnimatedOpacity(
          opacity: (currentRound >= playoffNode.series.round) ? 1.00 : 0.00,
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.teal, spreadRadius: 1),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(
                  image: finishedLoading
                      ? AssetImage(
                          "assets/team_${playoffNode.series.matchupTeams[0].team.id}.png")
                      : AssetImage("assets/blank.png"),
                  width: 70,
                  height: 70,
                ),
                Column(children: <Widget>[
                  Text(
                      finishedLoading
                          ? Utils.consistentVersus(
                              playoffNode.series.names.matchupShortName)
                          : 'Loading...',
                      style: whiteBoldText),
                  Text(
                      (finishedLoading &&
                              currentRound > playoffNode.series.round)
                          ? playoffNode.series.currentGame.seriesSummary
                              .seriesStatusShort
                          : ''.padLeft(
                              playoffNode.series.currentGame.seriesSummary
                                  .seriesStatusShort.length,
                              '  '),
                      style: whiteBoldText),
                ]),
                Image(
                  image: finishedLoading
                      ? AssetImage(
                          "assets/team_${playoffNode.series.matchupTeams[1].team.id}.png")
                      : AssetImage("assets/blank.png"),
                  width: 70,
                  height: 70,
                )
                // Image.asset('assets/team_2.png'),
              ],
            ),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Initially, call will begin at season 20182019
      generateGraphFromPlayoffs(20182019);
    });
    builder
      ..siblingSeparation = (25)
      ..levelSeparation = (25)
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_RIGHT_LEFT);
  }

  /// This async function fetches the playoff data from the NHL API, and then
  /// generates a new [Graph], updating the _graph variable. Returns [void].
  void generateGraphFromPlayoffs(int season) async {
    _playoffs = await Utils.fetchPlayoffs(season);

    // In the below code, we generate nodes for each playoff series
    // Stanley Cup Finals (1 series) ////////////////////
    Series series =
        _playoffs.rounds.firstWhere((r) => (r.number == 4)).seriesList[0];
    PlayoffNode root = PlayoffNode(id: 1, series: series);

    // Conference Finals (2 series) /////////////////////
    List<Series> seriesList =
        _playoffs.rounds.firstWhere((r) => (r.number == 3)).seriesList;
    PlayoffNode rootW = PlayoffNode(
        id: 2,
        series: seriesList.firstWhere((s) => s.conference.name == 'Western'));
    PlayoffNode rootE = PlayoffNode(
        id: 3,
        series: seriesList.firstWhere((s) => s.conference.name == 'Eastern'));

    // Conference Semifinals (4 series) /////////////////
    seriesList = _playoffs.rounds
        .firstWhere((r) => (r.number == 2))
        .seriesList
        .where((s) => s.conference.name == 'Western')
        .toList();
    PlayoffNode rootWChild1 = PlayoffNode(id: 4, series: seriesList[0]);
    PlayoffNode rootWChild2 = PlayoffNode(id: 5, series: seriesList[1]);

    seriesList = _playoffs.rounds
        .firstWhere((r) => (r.number == 2))
        .seriesList
        .where((s) => s.conference.name == 'Eastern')
        .toList();
    PlayoffNode rootEChild1 = PlayoffNode(id: 6, series: seriesList[0]);
    PlayoffNode rootEChild2 = PlayoffNode(id: 7, series: seriesList[1]);

    // Conference Quarterfinals (8 series) //////////////
    seriesList = _playoffs.rounds
        .firstWhere((r) => (r.number == 1))
        .seriesList
        .where((s) =>
            s.conference.name == 'Western' &&
            (s.matchupTeams[0].team.name ==
                    rootWChild1.series.matchupTeams[0].team.name ||
                s.matchupTeams[0].team.name ==
                    rootWChild1.series.matchupTeams[1].team.name ||
                s.matchupTeams[1].team.name ==
                    rootWChild1.series.matchupTeams[0].team.name ||
                s.matchupTeams[1].team.name ==
                    rootWChild1.series.matchupTeams[1].team.name))
        .toList();
    PlayoffNode rootWChild1Child1 = PlayoffNode(id: 8, series: seriesList[0]);
    PlayoffNode rootWChild1Child2 = PlayoffNode(id: 9, series: seriesList[1]);

    seriesList = _playoffs.rounds
        .firstWhere((r) => (r.number == 1))
        .seriesList
        .where((s) =>
            s.conference.name == 'Western' &&
            (s.matchupTeams[0].team.name ==
                    rootWChild2.series.matchupTeams[0].team.name ||
                s.matchupTeams[0].team.name ==
                    rootWChild2.series.matchupTeams[1].team.name ||
                s.matchupTeams[1].team.name ==
                    rootWChild2.series.matchupTeams[0].team.name ||
                s.matchupTeams[1].team.name ==
                    rootWChild2.series.matchupTeams[1].team.name))
        .toList();
    PlayoffNode rootWChild2Child1 = PlayoffNode(id: 10, series: seriesList[0]);
    PlayoffNode rootWChild2Child2 = PlayoffNode(id: 11, series: seriesList[1]);

    seriesList = _playoffs.rounds
        .firstWhere((r) => (r.number == 1))
        .seriesList
        .where((s) =>
            s.conference.name == 'Eastern' &&
            (s.matchupTeams[0].team.name ==
                    rootEChild1.series.matchupTeams[0].team.name ||
                s.matchupTeams[0].team.name ==
                    rootEChild1.series.matchupTeams[1].team.name ||
                s.matchupTeams[1].team.name ==
                    rootEChild1.series.matchupTeams[0].team.name ||
                s.matchupTeams[1].team.name ==
                    rootEChild1.series.matchupTeams[1].team.name))
        .toList();
    PlayoffNode rootEChild1Child1 = PlayoffNode(id: 12, series: seriesList[0]);
    PlayoffNode rootEChild1Child2 = PlayoffNode(id: 13, series: seriesList[1]);

    seriesList = _playoffs.rounds
        .firstWhere((r) => (r.number == 1))
        .seriesList
        .where((s) =>
            s.conference.name == 'Eastern' &&
            (s.matchupTeams[0].team.name ==
                    rootEChild2.series.matchupTeams[0].team.name ||
                s.matchupTeams[0].team.name ==
                    rootEChild2.series.matchupTeams[1].team.name ||
                s.matchupTeams[1].team.name ==
                    rootEChild2.series.matchupTeams[0].team.name ||
                s.matchupTeams[1].team.name ==
                    rootEChild2.series.matchupTeams[1].team.name))
        .toList();
    PlayoffNode rootEChild2Child1 = PlayoffNode(id: 14, series: seriesList[0]);
    PlayoffNode rootEChild2Child2 = PlayoffNode(id: 15, series: seriesList[1]);

    // In the below code, we generate a new graph, storing in _graph
    _graph = Graph();
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    _graph.addEdge(root, rootW, paint: paint);
    _graph.addEdge(root, rootE, paint: paint);
    _graph.addEdge(rootW, rootWChild1, paint: paint);
    _graph.addEdge(rootW, rootWChild2, paint: paint);
    _graph.addEdge(rootE, rootEChild1, paint: paint);
    _graph.addEdge(rootE, rootEChild2, paint: paint);

    _graph.addEdge(rootWChild1, rootWChild1Child1, paint: paint);
    _graph.addEdge(rootWChild1, rootWChild1Child2, paint: paint);
    _graph.addEdge(rootWChild2, rootWChild2Child1, paint: paint);
    _graph.addEdge(rootWChild2, rootWChild2Child2, paint: paint);

    _graph.addEdge(rootEChild1, rootEChild1Child1, paint: paint);
    _graph.addEdge(rootEChild1, rootEChild1Child2, paint: paint);
    _graph.addEdge(rootEChild2, rootEChild2Child1, paint: paint);
    _graph.addEdge(rootEChild2, rootEChild2Child2, paint: paint);

    builder
      ..siblingSeparation = (25)
      ..levelSeparation = (75)
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_RIGHT_LEFT);

    setState(() {
      finishedLoading = true;
    });
  }
}
