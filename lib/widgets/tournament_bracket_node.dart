import 'package:flutter/material.dart';
import 'package:tournament_app/widgets/series_popup.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/styles.dart';

/// This widget visualizes a node in our graph
Widget TournamentBracketNode(
    PlayoffNode playoffNode, BuildContext context, int currentRound) {
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
                image: AssetImage(
                    "assets/img/team_${playoffNode.series.teamOne}.png"),
                width: 70,
                height: 70,
              ),
              Column(children: <Widget>[
                Text(playoffNode.series.shortName, style: whiteBoldText),
                AnimatedOpacity(
                  opacity: (currentRound > playoffNode.roundNum) ? 1.00 : 0.00,
                  duration: const Duration(milliseconds: 500),
                  child: Text(playoffNode.series.shortResult,
                      style: whiteBoldText),
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
