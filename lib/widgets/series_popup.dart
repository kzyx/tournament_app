/// This file contains a class which represents the popup that is opened
/// when you press on a series in the playoff graph. In this popup, the user
/// can see stats/info for each game played in the series.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/utils.dart' as Utils;
import 'package:tournament_app/widgets/video_player_popup.dart';
import 'package:tournament_app/styles.dart';

/// This class represents a single game in the series list popup
class GameElement {
  GameElement({
    required this.gameIndex,
    required this.headerValue,
    this.isExpanded = false,
  });

  int gameIndex;
  String headerValue;
  bool isExpanded;
}

/// This widget is for the popup opened when you click a series for more info
class SeriesPopup extends StatefulWidget {
  final Series series;

  const SeriesPopup({Key? key, required this.series}) : super(key: key);

  @override
  State<SeriesPopup> createState() => _SeriesPopupState(this.series);
}

/// This is the private State class for the SeriesPopup
class _SeriesPopupState extends State<SeriesPopup> {
  late Series series;
  late List<GameElement> _data;

  _SeriesPopupState(this.series) {
    int numberOfGames = series.teamOneGamesWon + series.teamTwoGamesWon;
    _data = List<GameElement>.generate(numberOfGames,
        (i) => GameElement(gameIndex: i, headerValue: 'Game ${(i + 1)}'));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((GameElement item) {
        // Determine which team was home and which team was away, and
        // show their stats appropriately.
        int homeTeam = series.games[item.gameIndex].homeTeamId;
        bool homeTeamIsFirst = (series.teamOne == homeTeam);

        TeamGameStat team1 = homeTeamIsFirst
            ? series.games[item.gameIndex].teamGameStatOne
            : series.games[item.gameIndex].teamGameStatTwo;
        TeamGameStat team2 = homeTeamIsFirst
            ? series.games[item.gameIndex].teamGameStatTwo
            : series.games[item.gameIndex].teamGameStatOne;

        int scoredOne = team1.goalsScored;
        int attemptsOne = team1.goalsAttempted;
        int scoredTwo = team2.goalsScored;
        int attemptsTwo = team2.goalsAttempted;

        double savedPercentOne = (1 - (scoredTwo) / (attemptsTwo)) * 100;
        double savedPercentTwo = (1 - (scoredOne) / (attemptsOne)) * 100;

        // Determine whether the game has highlights. Old games in particular
        // don't have highlights (e.g. 2010 NHL playoff games).
        bool showHighlights = series.games[item.gameIndex].highlights != "N/A";

        return ExpansionPanel(
          backgroundColor: Colors.teal,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue, style: whiteBoldText),
            );
          },
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Table(
                      // border: TableBorder.,
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: <TableRow>[
                        TableRow(
                          children: [
                            Center(
                                child: Image(
                              image: AssetImage(
                                  "assets/img/team_${homeTeamIsFirst ? series.teamOne : series.teamTwo}.png"),
                              width: 70,
                              height: 70,
                            )),
                            Center(
                                child: Column(children: <Widget>[
                              Text(
                                  Utils.toAwayAtHomeString(
                                      series.shortName, homeTeamIsFirst),
                                  style: whiteBoldText),
                            ])),
                            Center(
                                child: Image(
                              image: AssetImage(
                                  "assets/img/team_${homeTeamIsFirst ? series.teamTwo : series.teamOne}.png"),
                              width: 70,
                              height: 70,
                            ))
                          ],
                        ),
                        TableRow(
                          children: [
                            Center(
                                child: Text(scoredOne.toString(),
                                    style: whiteBoldText)),
                            Center(child: Text("Goals", style: whiteBoldText)),
                            Center(
                                child: Text(scoredTwo.toString(),
                                    style: whiteBoldText)),
                          ],
                        ),
                        TableRow(
                          decoration: const BoxDecoration(),
                          children: <Widget>[
                            Center(
                                child: Text(attemptsOne.toString(),
                                    style: whiteBoldText)),
                            Center(
                                child: Text("Shots on goal",
                                    style: whiteBoldText)),
                            Center(
                                child: Text(attemptsTwo.toString(),
                                    style: whiteBoldText)),
                          ],
                        ),
                        TableRow(
                          decoration: const BoxDecoration(),
                          children: <Widget>[
                            Center(
                                child: Text(
                                    savedPercentOne.toStringAsFixed(1) + "%",
                                    style: whiteBoldText)),
                            Center(child: Text("Save %", style: whiteBoldText)),
                            Center(
                                child: Text(
                                    savedPercentTwo.toStringAsFixed(1) + "%",
                                    style: whiteBoldText)),
                          ],
                        ),
                      ],
                    )),
                const SizedBox(height: 30),
                if (showHighlights) ...[
                  ListTile(
                      title: const Text("Watch highlights",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      // subtitle: const Text(
                      //     'To delete this panel, tap the trash can icon'),
                      trailing: const Icon(Icons.video_collection),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return VideoPlayerPopup(
                                series.games[item.gameIndex].highlights,
                                UniqueKey());
                          },
                        );
                      })
                ]
              ]),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
