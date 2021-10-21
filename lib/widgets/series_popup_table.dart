/// This file contains classes and/or functions relating to the SeriesPopup
/// table contained within a SeriesPopup. For a single game, it displays game
/// information including header row (team logos), data rows (team stats),
/// and a highlights button.
import 'package:flutter/material.dart';
import 'package:tournament_app/styles.dart';
import 'package:tournament_app/widgets/video_player_popup.dart';
import 'package:tournament_app/models/all.dart';

/// Takes in [String] gameName and two [int]s homeTeamId, awayTeamId.
/// Returns the header of the SeriesPopup table, which is a [TableRow] of the
/// form (<LOGO OF AWAY TEAM>, gameName, <LOGO OF HOME TEAM>).
TableRow generateSeriesPopupHeaderRow(
    String gameName, int homeTeamId, int awayTeamId) {
  return TableRow(
    children: [
      Center(
          child: Image(
        image: AssetImage("assets/img/team_$homeTeamId.png"),
        width: 70,
        height: 70,
      )),
      Center(
          child: Column(children: <Widget>[
        Text(gameName, style: whiteTextStyle),
      ])),
      Center(
          child: Image(
        image: AssetImage("assets/img/team_$awayTeamId.png"),
        width: 70,
        height: 70,
      ))
    ],
  );
}

/// Takes in [String]s statName, statTeamOne, statTeamTwo.
/// Returns one row of data in the SeriesPopup of the form
/// (statTeamOne, statName, statTeamTwo).
TableRow generateSeriesPopupDataRow(
    String statName, String statTeamOne, String statTeamTwo) {
  return TableRow(
    children: <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Center(child: Text(statTeamOne, style: whiteTextStyle))),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Center(child: Text(statName, style: whiteTextStyle))),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Center(child: Text(statTeamTwo, style: whiteTextStyle))),
    ],
  );
}

/// Returns a button that, when clicked, opens a video player that plays
/// the video at the provided [String] highlightsURL.
Widget generateSeriesPopupHighlightButton(
    BuildContext context, String highlightsURL) {
  return ListTile(
      title: const Text("Watch highlights",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
      trailing: const Icon(Icons.video_collection),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return VideoPlayerPopup(highlightsURL, UniqueKey());
          },
        );
      });
}

/// Takes arguments gameName [String] (e.g. "DAL @ VAN"), as well as [int]s
/// for the home and away team IDs, and [TeamGameStat]s for each team.
/// Returns [Table] containing the info about the given game, with away team's
/// stats on the left and the home team's stats on the right.
Table generateSeriesPopupTable(String gameName, int homeTeamId, int awayTeamId,
    TeamGameStat awayTeamStat, TeamGameStat homeTeamStat) {
  return Table(
    columnWidths: const <int, TableColumnWidth>{
      0: FlexColumnWidth(0.8),
      1: FlexColumnWidth(1), // Middle text column is bigger
      2: FlexColumnWidth(0.8),
    },
    defaultVerticalAlignment:
    TableCellVerticalAlignment.middle,
    children: [
      generateSeriesPopupHeaderRow(
          gameName,
          homeTeamId,
          awayTeamId),
      generateSeriesPopupDataRow(
          "Goals",
          awayTeamStat.goalsScored.toString(),
          homeTeamStat.goalsScored.toString()),
      generateSeriesPopupDataRow(
          "Shots taken",
          awayTeamStat.goalsAttempted.toString(),
          homeTeamStat.goalsAttempted.toString()),
      generateSeriesPopupDataRow(
          "Shots blocked",
          awayTeamStat.blocked.toString(),
          homeTeamStat.blocked.toString()),
      generateSeriesPopupDataRow(
          "PP Goals",
          awayTeamStat.powerPlayGoals.toString(),
          homeTeamStat.powerPlayGoals.toString()),
      generateSeriesPopupDataRow(
          "PP Percentage",
          awayTeamStat.powerPlayPercentage.toString() + "%",
          homeTeamStat.powerPlayPercentage.toString() + "%"),
      generateSeriesPopupDataRow(
          "Hits",
          awayTeamStat.hits.toString(),
          homeTeamStat.hits.toString()),
      generateSeriesPopupDataRow(
          "Penalty min",
          awayTeamStat.penaltyMin.toString(),
          homeTeamStat.penaltyMin.toString()),
      generateSeriesPopupDataRow(
          "Takeaways",
          awayTeamStat.takeaways.toString(),
          homeTeamStat.takeaways.toString()),
      generateSeriesPopupDataRow(
          "Giveaways",
          awayTeamStat.giveaways.toString(),
          homeTeamStat.giveaways.toString()),
    ],
  );
}