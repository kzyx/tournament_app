import 'package:tournament_app/models/enum.dart';
import 'package:tournament_app/models/game.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:graphview/GraphView.dart';

/// Represents a single series played in a round of a playoff season
class Series {
  Series({
    required this.shortName,
    required this.longName,
    required this.shortResult,
    required this.longResult,
    required this.teamOne,
    required this.teamTwo,
    required this.teamOneGamesWon,
    required this.teamTwoGamesWon,
    required this.conference,
    required this.games,
  });
  String shortName;
  String longName;
  String shortResult;
  String longResult;
  int teamOne;
  int teamTwo;
  int teamOneGamesWon;
  int teamTwoGamesWon;
  Conference conference;
  List<Game> games;

  factory Series.fromRawJson(String str) => Series.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Series.fromJson(Map<String, dynamic> json) => Series(
        shortName: json["shortName"],
        longName: json["longName"],
        shortResult: json["shortResult"],
        longResult: json["longResult"],
        teamOne: json["teamOne"],
        teamTwo: json["teamTwo"],
        teamOneGamesWon: json["teamOneGamesWon"],
        teamTwoGamesWon: json["teamTwoGamesWon"],
        conference: conferenceValues.map[json["conference"]]!,
        games: List<Game>.from(json["games"].map((x) => Game.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "teamOne": teamOne,
        "teamTwo": teamTwo,
        "teamOneGamesWon": teamOneGamesWon,
        "teamTwoGamesWon": teamTwoGamesWon,
        "conference": conferenceValues.reverse[conference],
        "games": List<dynamic>.from(games.map((x) => x.toJson())),
      };
}

enum Conference { EASTERN, N_A, WESTERN }

final conferenceValues = EnumValues({
  "Eastern": Conference.EASTERN,
  "N/A": Conference.N_A,
  "Western": Conference.WESTERN
});
