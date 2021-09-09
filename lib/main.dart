import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'playoff_series.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        home: TreeViewPage(),
      );
}

class TreeViewPage extends StatefulWidget {
  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  late Playoffs playoffs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Wrap(
              children: [
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.siblingSeparation.toString(),
                    decoration: InputDecoration(
                        labelText: "Sibling Separation"),
                    onChanged: (text) {
                      builder.siblingSeparation = int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.levelSeparation.toString(),
                    decoration: InputDecoration(labelText: "Level Separation"),
                    onChanged: (text) {
                      builder.levelSeparation = int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.subtreeSeparation.toString(),
                    decoration: InputDecoration(
                        labelText: "Subtree separation"),
                    onChanged: (text) {
                      builder.subtreeSeparation = int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: builder.orientation.toString(),
                    decoration: InputDecoration(labelText: "Orientation"),
                    onChanged: (text) {
                      builder.orientation = int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    // final node12 = Node(rectangleWidget(r.nextInt(100)));
                    // var edge =
                    //     graph.getNodeAtPosition(r.nextInt(graph.nodeCount()));
                    // print(edge);
                    // graph.addEdge(edge, node12);
                    // setState(() {});
                  },
                  child: PlayoffsYearDropdown(),
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
        ));
  }

  Random r = Random();

  Widget rectangleWidget(PlayoffNode playoffNode) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
          padding: EdgeInsets.all(16),
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
                image: AssetImage("assets/team_${playoffNode.series.matchupTeams[0].team.id}.png"),
                width: 200,
                height: 200,
              ),
              Text('Node ${playoffNode.series.names.matchupShortName}'),
              // Image.asset('assets/team_2.png'),
            ],
          ),
      ),
    );
  }

  final Graph graph = Graph()
    ..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    // await fetchPlayoffs(20182019)//.then((Playoffs fetchedPlayoffs) {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _asyncMethod();
    });
    builder
      ..siblingSeparation = (25)
      ..levelSeparation = (25)
      ..subtreeSeparation = (25)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);
  }

  void _asyncMethod() async {
    playoffs = await fetchPlayoffs(20182019);

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
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);

    setState(() {
    });
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
  final List<String> playoffsYear = ['2016-2017', '2017-2018', '2018-2019'];

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
        setState(() {
          dropdownValue = newValue!;
        });
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

Future<Playoffs> fetchPlayoffs(int season) async {
  const baseUrl = 'https://statsapi.web.nhl.com/api/v1/tournaments/playoffs';
  const additionalUrl = '?expand=round.series,schedule.game.seriesSummary';
  final response =
  await http.get(Uri.parse(baseUrl + additionalUrl + '&season=$season'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    // List<dynamic> jsonList = jsonMap["rounds"];
    Playoffs playoffs = Playoffs.fromJson(jsonMap);
    return playoffs;
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load teams from statsapi.web.nhl.com');
  }
}
