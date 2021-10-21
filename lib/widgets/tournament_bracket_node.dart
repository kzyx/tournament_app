/// This file contains classes and/or functions relating to a single node in
/// our playoff graph. This node contains information about a single series
/// that was played, and displays team icons and
import 'package:flutter/material.dart';
import 'package:tournament_app/widgets/series_popup.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/styles.dart';

/// This widget visualizes a node in our playoff graph.
/// It has a logo icon of one team on the left, and the other team on the right.
/// In the center there is some text that says "TEAM1 vs TEAM2" and directly
/// below that there is text that gives the result (e.g. "TEAM2 won 4-3").
Widget generateTournamentBracketNode(
    PlayoffNode playoffNode, BuildContext context) {
  return InkWell(
    onTap: () {
      if (playoffNode.currentRound >= playoffNode.roundNum) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 16,
                backgroundColor: secondaryColor,
                child: SeriesPopup(series: playoffNode.series));
          },
        );
      }
    },
    child: AnimatedOpacity(
        opacity:
            (playoffNode.currentRound >= playoffNode.roundNum) ? 1.00 : 0.00,
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: primaryColor, spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                image: AssetImage(
                    "assets/img/team_${playoffNode.series.teamOne}.png"),
                width: 70,
                height: 70,
              ),
              Column(children: <Widget>[
                Text(playoffNode.series.shortName, style: whiteTextStyle),
                AnimatedOpacity(
                  opacity: (playoffNode.currentRound > playoffNode.roundNum)
                      ? 1.00
                      : 0.00,
                  duration: const Duration(milliseconds: 500),
                  child: Text(playoffNode.series.shortResult,
                      style: whiteTextStyle),
                )
              ]),
              Image(
                image: AssetImage(
                    "assets/img/team_${playoffNode.series.teamTwo}.png"),
                width: 70,
                height: 70,
              )
            ],
          ),
        )),
  );
}
