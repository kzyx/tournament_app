import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'playoff_series.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils.dart';

void main() {
  runApp(MyApp());
}

// Key allows Dropdown widget to call method inside TreeView
GlobalKey<_TreeViewPageState> _myKey = GlobalKey();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        home: TreeViewPage(key: _myKey),
      );
}

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({Key? key}) : super(key: key);
  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  late Playoffs playoffs;
  int currentRound = 1;
  bool finishedLoading = false;
  Graph graph = Graph()
    ..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  // Widget _body = CircularProgressIndicator();

  @override
  Widget build(BuildContext context) {
    if (!finishedLoading) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
          body: Container(
          margin: const EdgeInsets.only(top: 80.0, bottom: 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Wrap(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      PlayoffsYearDropdown(),
                      FloatingActionButton.extended(label: Text("Prev\nRound"),
                        onPressed: () {
                          // Add your onPressed code here!
                          setState((){
                            if (currentRound >= 2) {
                              currentRound -= 1;
                            }
                          });
                        },
                        // child: const Text("Remove"),
                        backgroundColor: Colors.green,
                      ),
                      Text(currentRound.toString()),
                      FloatingActionButton.extended(label: Text("Next\nRound"),
                        onPressed: () {
                          // Add your onPressed code here!
                          setState((){
                            if (currentRound <= 3) {
                              currentRound += 1;
                            }
                          });
                        },
                        // child: const Text("Add"),
                        backgroundColor: Colors.green,
                      ),
                    ],
                  )
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: EdgeInsets.all(100),
                    minScale: 0.01,
                    maxScale: 5.6,
                    child: GraphView(
                      graph: graph,
                      algorithm:
                      BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                      paint: Paint()
                        ..color = Colors.green
                        ..strokeWidth = 1
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        // I can decide what widget should be shown here based on the id
                        // var a = node.key?.value as int;
                        return rectangleWidget(node as PlayoffNode);
                      },
                    )),
              ),
            ],
          ))
      );
    }
  }

  Widget rectangleWidget(PlayoffNode playoffNode) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.blue, spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                image: finishedLoading ? AssetImage("assets/team_${playoffNode.series.matchupTeams[0].team.id}.png") : AssetImage("assets/blank.png"),
                width: 70,
                height: 70,
              ),
              Text(finishedLoading ? consistentVersus(playoffNode.series.names.matchupShortName) : 'Loading...'),
              Image(
                image: finishedLoading ? AssetImage("assets/team_${playoffNode.series.matchupTeams[1].team.id}.png") : AssetImage("assets/blank.png"),
                width: 70,
                height: 70,
              )
              // Image.asset('assets/team_2.png'),
            ],
          ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Initially, call will begin at season 20182019
      _asyncMethod(20182019);
    });
    builder
      ..siblingSeparation = (25)
      ..levelSeparation = (25)
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_RIGHT_LEFT);
  }

  void _asyncMethod(int season) async {
    playoffs = await fetchPlayoffs(season);
    debugPrint("TODO: got to check111");
    // Stanley Cup Finals (1 series) ////////////////////
    Series series = playoffs.rounds
        .where((r) => (r.number == 4))
        .toList()[0]
        .seriesList[0];
    PlayoffNode root = PlayoffNode(id: 1, series: series);

    // Conference Finals (2 series) /////////////////////
    List<Series> seriesList =
        playoffs.rounds.where((r) => (r.number == 3)).toList()[0].seriesList;
    PlayoffNode rootW = PlayoffNode(
        id: 2,
        series: seriesList.firstWhere((s) => s.conference.name == 'Western'));
    PlayoffNode rootE = PlayoffNode(
        id: 3,
        series: seriesList.firstWhere((s) => s.conference.name == 'Eastern'));

    // Conference Semifinals (4 series) /////////////////
    seriesList = playoffs.rounds
        .firstWhere((r) => (r.number == 2))
        .seriesList
        .where((s) => s.conference.name == 'Western')
        .toList();
    PlayoffNode rootWChild1 = PlayoffNode(id: 4, series: seriesList[0]);
    PlayoffNode rootWChild2 = PlayoffNode(id: 5, series: seriesList[1]);

    seriesList = playoffs.rounds
        .firstWhere((r) => (r.number == 2))
        .seriesList
        .where((s) => s.conference.name == 'Eastern')
        .toList();
    PlayoffNode rootEChild1 = PlayoffNode(id: 6, series: seriesList[0]);
    PlayoffNode rootEChild2 = PlayoffNode(id: 7, series: seriesList[1]);

    // Conference Quarterfinals (8 series) //////////////
    seriesList = playoffs.rounds
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

    seriesList = playoffs.rounds
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
    PlayoffNode rootWChild2Child1 =
    PlayoffNode(id: 10, series: seriesList[0]);
    PlayoffNode rootWChild2Child2 =
    PlayoffNode(id: 11, series: seriesList[1]);

    seriesList = playoffs.rounds
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

    seriesList = playoffs.rounds
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

    graph = Graph();
    graph.addEdge(root, rootW);
    graph.addEdge(root, rootE);
    graph.addEdge(rootW, rootWChild1, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootW, rootWChild2, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootE, rootEChild1, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootE, rootEChild2, paint: Paint()
      ..color = Colors.red);

    graph.addEdge(rootWChild1, rootWChild1Child1, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootWChild1, rootWChild1Child2, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootWChild2, rootWChild2Child1, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootWChild2, rootWChild2Child2, paint: Paint()
      ..color = Colors.red);

    graph.addEdge(rootEChild1, rootEChild1Child1, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootEChild1, rootEChild1Child2, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootEChild2, rootEChild2Child1, paint: Paint()
      ..color = Colors.red);
    graph.addEdge(rootEChild2, rootEChild2Child2, paint: Paint()
      ..color = Colors.red);

    builder
      ..siblingSeparation = (25)
      ..levelSeparation = (25)
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_RIGHT_LEFT);

    setState(() {
      finishedLoading = true;
    });
    debugPrint("got here 2222");
  }

}

/// This is the stateful widget that the main application instantiates.
class PlayoffsYearDropdown extends StatefulWidget {
  const PlayoffsYearDropdown({Key? key}) : super(key: key);

  @override
  State<PlayoffsYearDropdown> createState() => _PlayoffsYearDropdownState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _PlayoffsYearDropdownState extends State<PlayoffsYearDropdown> {
  String dropdownValue = '2018-2019';
  final List<String> playoffsYear = List<String>.generate(6,
      (i) => '20${(i + 13).toString().padLeft(2, '0')}'
          '-20${(i + 14).toString().padLeft(2, '0')}');

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        if (newValue == dropdownValue) {
          return;
        }
        int season = int.parse(newValue!.substring(0, 4) + newValue.substring(5));
        setState(() {
          dropdownValue = newValue;
          _myKey.currentState!.finishedLoading = false;
          debugPrint(season.toString());
        });
        _myKey.currentState!._asyncMethod(season);
      },
      items: playoffsYear.map((playoffsYear) {
        return DropdownMenuItem<String>(
          value: playoffsYear,
          child: Text(playoffsYear),
        );
      }).toList(),
    );
  }
}

class PlayoffNode extends Node {
  late Series series;

  PlayoffNode({required int id, required Series series}) : super.Id(id) {
    this.series = series;
  }
}