import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'dart:convert';
import 'finals_round.dart';

class Tournament extends StatefulWidget {
  // This class is the configuration for the state.
  // It holds the values (in this case nothing) provided
  // by the parent and used by the build  method of the
  // State. Fields in a Widget subclass are always marked
  // "final".

  List<Team> teamList = [
    Team(
        id: 0,
        name: 'name',
        abbreviation: 'abbrev',
        conference: 'conf',
        franchiseId: 0)
  ];

  Tournament({Key? key}) : super(key: key) {
    // Use API to load (teamID, teamName) pairs from NHL API
    fetchTeamIDs().then((List<Team> fetchedTeamList) {
      teamList = fetchedTeamList;
      // TODO: Remove print statement
      // teamName.forEach((k, v) => print('${k}: ${v}'));
    });
  }

  @override
  _TournamentState createState() => _TournamentState();
}

class _TournamentState extends State<Tournament> {
  // We are using the same format 'int Year1Year2' that NHL APIs use
  int _seasonID = 20182019;
  int _round = 3;

  void _increment() {
    setState(() {
      // This call to setState tells the Flutter framework
      // that something has changed in this State, which
      // causes it to rerun the build method below so that
      // the display can reflect the updated values. If you
      // change _counter without calling setState(), then
      // the build method won't be called again, and so
      // nothing would appear to happen.
      _seasonID++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called,
    // for instance, as done by the _increment method above.
    // The Flutter framework has been optimized to make
    // rerunning build methods fast, so that you can just
    // rebuild anything that needs updating rather than
    // having to individually changes instances of widgets.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Increment'),
        ),
        const SizedBox(width: 16),
        Text('Count: $_seasonID'),
        Image(
          image: AssetImage("assets/team_1.png"),
          width: 200,
          height: 200,
        )
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Tournament(),
        ),
      ),
    ),
  );
}

/// Fetches Team IDs using the NHL API
Future<List<Team>> fetchTeamIDs() async {
  final response =
      await http.get(Uri.parse('https://statsapi.web.nhl.com/api/v1/teams'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    List<dynamic> jsonTeamList = jsonMap["teams"];
    List<Team> outputTeams = [];
    for (var jsonTeam in jsonTeamList) {
      outputTeams.add(Team.fromJson(jsonTeam));
      debugPrint(outputTeams.last.name);
    }
    debugPrint(outputTeams.length.toString());
    return outputTeams;
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load teams from statsapi.web.nhl.com');
  }
}

Future<List<Team>> fetchPlayoffRound() async {
  final response =
      await http.get(Uri.parse('https://statsapi.web.nhl.com/api/v1/teams'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    List<dynamic> jsonTeamList = jsonMap["teams"];
    List<Team> outputTeams = [];
    for (var jsonTeam in jsonTeamList) {
      outputTeams.add(Team.fromJson(jsonTeam));
      debugPrint(outputTeams.last.name);
    }
    debugPrint(outputTeams.length.toString());
    return outputTeams;
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load teams from statsapi.web.nhl.com');
  }
}
