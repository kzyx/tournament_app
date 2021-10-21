/// This file contains classes and/or functions relating to the SeriesPopup
/// table for a single game. It displays game information including
/// header row (team logos), data rows (team stats), and a highlights button.
import 'package:flutter/material.dart';
import 'package:tournament_app/styles.dart';
import 'package:tournament_app/widgets/video_player_popup.dart';

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
///
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
ListTile generateSeriesPopupHighlightButton(
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
