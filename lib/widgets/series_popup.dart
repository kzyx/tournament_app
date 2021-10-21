/// This file contains functions and/or classes which represents the popup
/// that is opened when you press on a series in the playoff graph. In this
/// popup, the user can see stats/info for each game played in the series.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/utils.dart' as utils;
import 'package:tournament_app/styles.dart';
import 'package:tournament_app/widgets/series_popup_table.dart';

/// This class represents one entry of the ExpandableList that stores all the
/// games in the SeriesPopup class.
class GameElement {
  GameElement({
    required this.gameIndex,
    required this.gameTitle,
    this.isExpanded = false,
  });

  int gameIndex; // represents index of corresponding game in series.games
  String gameTitle; // e.g. "Game 1"
  bool isExpanded;
}

/// This widget is for the popup opened when you click a series for more info.
class SeriesPopup extends StatefulWidget {
  final Series series;

  const SeriesPopup({Key? key, required this.series}) : super(key: key);

  @override
  State<SeriesPopup> createState() => _SeriesPopupState(series);
}

/// This is the private State class for the SeriesPopup.
class _SeriesPopupState extends State<SeriesPopup> {
  late Series series;
  late List<GameElement> _data;

  _SeriesPopupState(this.series) {
    // Determine number of games played and make an expandable list with
    // a corresponding number of entries
    int numberOfGames = series.teamOneGamesWon + series.teamTwoGamesWon;
    _data = List<GameElement>.generate(numberOfGames,
        (i) => GameElement(gameIndex: i, gameTitle: 'Game ${(i + 1)}'));
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
      // Toggle expanded when header is pressed
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((GameElement item) {
        // Determine which team was home and which team was away, and
        // show their stats appropriately (we want AWAY on left, HOME on right)
        int homeTeamId = series.games[item.gameIndex].homeTeamId;
        bool homeTeamIsFirst = (series.teamOne == homeTeamId);
        int awayTeamId = (homeTeamIsFirst) ? series.teamTwo : series.teamOne;

        TeamGameStat teamOneStat = homeTeamIsFirst
            ? series.games[item.gameIndex].teamGameStatOne
            : series.games[item.gameIndex].teamGameStatTwo;
        TeamGameStat teamTwoStat = homeTeamIsFirst
            ? series.games[item.gameIndex].teamGameStatTwo
            : series.games[item.gameIndex].teamGameStatOne;

        // Determine whether the game has highlights. Old games in particular
        // don't have highlights available (e.g. 2007 NHL playoff games).
        bool showHighlights = series.games[item.gameIndex].highlights != "N/A";

        return ExpansionPanel(
          canTapOnHeader: true, // Allows expansion on tap anywhere on header
          backgroundColor: primaryColor,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.gameTitle, style: whiteTextStyle),
            );
          },
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Table(
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(0.8),
                        1: FlexColumnWidth(1), // Middle text column is bigger
                        2: FlexColumnWidth(0.8),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        generateSeriesPopupHeaderRow(
                            utils.toAwayAtHomeString(
                                series.shortName, homeTeamIsFirst),
                            homeTeamId,
                            awayTeamId),
                        generateSeriesPopupDataRow(
                            "Goals",
                            teamOneStat.goalsScored.toString(),
                            teamTwoStat.goalsScored.toString()),
                        generateSeriesPopupDataRow(
                            "Shots taken",
                            teamOneStat.goalsAttempted.toString(),
                            teamTwoStat.goalsAttempted.toString()),
                        generateSeriesPopupDataRow(
                            "Shots blocked",
                            teamOneStat.blocked.toString(),
                            teamTwoStat.blocked.toString()),
                        generateSeriesPopupDataRow(
                            "PP Goals",
                            teamOneStat.powerPlayGoals.toString(),
                            teamTwoStat.powerPlayGoals.toString()),
                        generateSeriesPopupDataRow(
                            "PP Percentage",
                            teamOneStat.powerPlayPercentage.toString() + "%",
                            teamTwoStat.powerPlayPercentage.toString() + "%"),
                        generateSeriesPopupDataRow(
                            "Hits",
                            teamOneStat.hits.toString(),
                            teamTwoStat.hits.toString()),
                        generateSeriesPopupDataRow(
                            "Penalty min",
                            teamOneStat.penaltyMin.toString(),
                            teamTwoStat.penaltyMin.toString()),
                        generateSeriesPopupDataRow(
                            "Takeaways",
                            teamOneStat.takeaways.toString(),
                            teamTwoStat.takeaways.toString()),
                        generateSeriesPopupDataRow(
                            "Giveaways",
                            teamOneStat.giveaways.toString(),
                            teamTwoStat.giveaways.toString()),
                      ],
                    )),
                const SizedBox(height: 20),
                if (showHighlights) ...[
                  generateSeriesPopupHighlightButton(
                      context, series.games[item.gameIndex].highlights)
                ]
              ]),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
