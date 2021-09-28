import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/dropdown.dart';
import 'package:tournament_app/series_popup.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/utils.dart' as Utils;
import 'package:tuple/tuple.dart';

// Key allows Dropdown widget to call method inside TreeViewPage.
// In some languages the use of global variables is frowned upon, so in the
// future it could be advisable to replace this.
GlobalKey<_TournamentBracketState> treeViewPageKey = GlobalKey();

// Some default text styles
const TextStyle whiteBoldText =
    TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white);
const TextStyle blackBoldText =
    TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black);

/// This widget is for the page with the tree view playoff bracket
class TournamentBracket extends StatefulWidget {
  const TournamentBracket({Key? key}) : super(key: key);

  @override
  _TournamentBracketState createState() => _TournamentBracketState();
}

/// This is the private State class for the TreeViewPage
class _TournamentBracketState extends State<TournamentBracket> {
  bool finishedLoading = false; // Boolean representing whether API call done
  int currentRound = 5; // Set to 5 (i.e. playoffs over)
  Graph _graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  late final List<PlayoffSeason> _playoffs;
  late TransformationController _controller;

  @override
  Widget build(BuildContext context) {
    if (!finishedLoading) {
      return loadingScreenWidget();
    } else {
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

  AppBar buildTopAppBar() {
    return AppBar(
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const PlayoffsYearDropdown(),
            SizedBox(width: 30),
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
      centerTitle: true,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      firstTimeLoad();
    });
    // Set up some graph options
    builder
      ..siblingSeparation = (25)
      ..levelSeparation = (25)
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_RIGHT_LEFT);

    // Initialize controller for InteractiveViewer
    _controller = TransformationController();
    _controller.value = Matrix4.identity() * 0.8;
  }

  /// This widget visualizes a node in our graph
  Widget rectangleWidget(PlayoffNode playoffNode) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 16,
                backgroundColor: Colors.orange,
                child: SeriesPopup(series: playoffNode.series));
          },
        );
      },
      child: AnimatedOpacity(
          opacity: (currentRound >= playoffNode.roundNum) ? 1.00 : 0.00,
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
                          "assets/img/team_${playoffNode.series.teamOne}.png")
                      : AssetImage("assets/img/blank.png"),
                  width: 70,
                  height: 70,
                ),
                Column(children: <Widget>[
                  Text(
                      finishedLoading
                          ? Utils.consistentVersus(playoffNode.series.shortName)
                          : 'Loading...',
                      style: whiteBoldText),
                  AnimatedOpacity(
                    opacity: (finishedLoading &&
                            (currentRound > playoffNode.roundNum))
                        ? 1.00
                        : 0.00,
                    duration: const Duration(milliseconds: 500),
                    child: Text(playoffNode.series.shortResult,
                        style: whiteBoldText),
                  )
                ]),
                Image(
                  image: finishedLoading
                      ? AssetImage(
                          "assets/img/team_${playoffNode.series.teamTwo}.png")
                      : AssetImage("assets/img/blank.png"),
                  width: 70,
                  height: 70,
                )
              ],
            ),
          )),
    );
  }

  void firstTimeLoad() async {
    _playoffs = await Utils.loadAllPlayoffData();
    generateGraphFromPlayoffs(20182019);
  }

  /// This async function fetches the playoff data from the NHL API, and then
  /// generates a new [Graph], updating the _graph variable. Returns [void].
  void generateGraphFromPlayoffs(int season) {
    // Async fetch both list of games and playoff bracket data
    // Await the playoff bracket data since that is essential for the graph

    int idx = _playoffs.indexWhere((s) => s.seasonNum == season);

    // In the below code, we generate nodes for each playoff series
    // Stanley Cup Finals (1 series) ////////////////////
    Series series = _playoffs[idx]
        .rounds
        .firstWhere((r) => (r.roundNum == 4))
        .seriesList[0];
    PlayoffNode root = PlayoffNode(id: 1, series: series, roundNum: 4);

    // Conference Finals (2 series) /////////////////////
    List<Series> seriesList =
        _playoffs[idx].rounds.firstWhere((r) => (r.roundNum == 3)).seriesList;
    PlayoffNode rootW = PlayoffNode(
        id: 2,
        series:
            seriesList.firstWhere((s) => s.conference == Conference.WESTERN),
        roundNum: 3);
    PlayoffNode rootE = PlayoffNode(
        id: 3,
        series:
            seriesList.firstWhere((s) => s.conference == Conference.EASTERN),
        roundNum: 3);

    // Conference Semifinals (4 series) /////////////////
    int idx_w1 =
        _playoffs[idx].getIndexOfMatchingSeries(2, rootW.series.teamOne);
    int idx_w2 =
        _playoffs[idx].getIndexOfMatchingSeries(2, rootW.series.teamTwo);
    int idx_e1 =
        _playoffs[idx].getIndexOfMatchingSeries(2, rootE.series.teamOne);
    int idx_e2 =
        _playoffs[idx].getIndexOfMatchingSeries(2, rootE.series.teamTwo);
    Series s_w1 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 2)
        .seriesList[idx_w1];
    Series s_w2 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 2)
        .seriesList[idx_w2];
    Series s_e1 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 2)
        .seriesList[idx_e1];
    Series s_e2 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 2)
        .seriesList[idx_e2];
    PlayoffNode rootWChild1 = PlayoffNode(id: 4, series: s_w1, roundNum: 2);
    PlayoffNode rootWChild2 = PlayoffNode(id: 5, series: s_w2, roundNum: 2);
    PlayoffNode rootEChild1 = PlayoffNode(id: 6, series: s_e1, roundNum: 2);
    PlayoffNode rootEChild2 = PlayoffNode(id: 7, series: s_e2, roundNum: 2);

    // Conference Quarterfinals (8 series) //////////////
    // Find the next elemnts of the tree by looking for the series in round 1
    // with matching team names
    int idx_w11 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootWChild1.series.teamOne);
    int idx_w12 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootWChild1.series.teamTwo);
    int idx_w21 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootWChild2.series.teamOne);
    int idx_w22 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootWChild2.series.teamTwo);
    int idx_e11 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootEChild1.series.teamOne);
    int idx_e12 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootEChild1.series.teamTwo);
    int idx_e21 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootEChild2.series.teamOne);
    int idx_e22 =
        _playoffs[idx].getIndexOfMatchingSeries(1, rootEChild2.series.teamTwo);
    Series s_w11 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_w11];
    Series s_w12 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_w12];
    Series s_w21 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_w21];
    Series s_w22 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_w22];
    Series s_e11 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_e11];
    Series s_e12 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_e12];
    Series s_e21 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_e21];
    Series s_e22 = _playoffs[idx]
        .rounds
        .firstWhere((r) => r.roundNum == 1)
        .seriesList[idx_e22];
    PlayoffNode rootWChild1Child1 =
        PlayoffNode(id: 8, series: s_w11, roundNum: 1);
    PlayoffNode rootWChild1Child2 =
        PlayoffNode(id: 9, series: s_w12, roundNum: 1);
    PlayoffNode rootWChild2Child1 =
        PlayoffNode(id: 10, series: s_w21, roundNum: 1);
    PlayoffNode rootWChild2Child2 =
        PlayoffNode(id: 11, series: s_w22, roundNum: 1);
    PlayoffNode rootEChild1Child1 =
        PlayoffNode(id: 12, series: s_e11, roundNum: 1);
    PlayoffNode rootEChild1Child2 =
        PlayoffNode(id: 13, series: s_e12, roundNum: 1);
    PlayoffNode rootEChild2Child1 =
        PlayoffNode(id: 14, series: s_e21, roundNum: 1);
    PlayoffNode rootEChild2Child2 =
        PlayoffNode(id: 15, series: s_e22, roundNum: 1);

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

  /// This widget shows a circular loading symbol in the center of the screen
  Widget loadingScreenWidget() {
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

  /// Returns list of all the playoffs
  List<int> getAllPlayoffYearNumbers() {
    List<int> output = [];
    for (int i = 0; i < _playoffs.length; i++) {
      output.add(_playoffs[i].seasonNum);
    }
    output.sort((int a, int b) => a.compareTo(b));
    return output;
  }
}
