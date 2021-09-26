// To parse this JSON data, do
//
//     final playoffSeason = playoffSeasonFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:graphview/GraphView.dart';

/// Represents node in graph/tree generated using Playoffs object
class PlayoffNode extends Node {
  late Series series;
  late int roundNum;

  PlayoffNode({required int id, required Series series, required int roundNum}) : super.Id(id) {
    this.series = series;
    this.roundNum = roundNum;
  }
}

class PlayoffSeason {
  PlayoffSeason({
    required this.seasonNum,
    required this.rounds,
  });

  int seasonNum;
  List<Round> rounds;

  factory PlayoffSeason.fromRawJson(String str) =>
      PlayoffSeason.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PlayoffSeason.fromJson(Map<String, dynamic> json) => PlayoffSeason(
        seasonNum: int.parse(json["seasonNum"]),
        rounds: List<Round>.from(json["rounds"].map((x) => Round.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "seasonNum": seasonNum.toString(),
        "rounds": List<dynamic>.from(rounds.map((x) => x.toJson())),
      };
}

class Round {
  Round({
    required this.roundNum,
    required this.roundName,
    required this.seriesList,
  });

  int roundNum;
  Name roundName;
  List<Series> seriesList;

  factory Round.fromRawJson(String str) => Round.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        roundNum: json["roundNum"],
        roundName: nameValues.map[json["roundName"]]!,
        seriesList: List<Series>.from(
            json["seriesList"].map((x) => Series.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "roundNum": roundNum,
        "roundName": nameValues.reverse[roundName],
        "seriesList": List<dynamic>.from(seriesList.map((x) => x.toJson())),
      };
}

enum Name {
  CONFERENCE_QUARTERFINALS,
  CONFERENCE_SEMIFINALS,
  CONFERENCE_FINALS,
  STANLEY_CUP_FINALS
}

final nameValues = EnumValues({
  "Conference Finals": Name.CONFERENCE_FINALS,
  "Conference Quarterfinals": Name.CONFERENCE_QUARTERFINALS,
  "Conference Semifinals": Name.CONFERENCE_SEMIFINALS,
  "Stanley Cup Finals": Name.STANLEY_CUP_FINALS
});

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

class Game {
  Game({
    required this.gameId,
    required this.teamGameStatOne,
    required this.teamGameStatTwo,
    required this.victorId,
    required this.homeTeamId,
    required this.venue,
    required this.highlights,
  });

  int gameId;
  TeamGameStat teamGameStatOne;
  TeamGameStat teamGameStatTwo;
  int victorId;
  int homeTeamId;
  String venue;
  String highlights;

  factory Game.fromRawJson(String str) => Game.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        gameId: json["gameId"],
        teamGameStatOne: TeamGameStat.fromJson(json["teamGameStatOne"]),
        teamGameStatTwo: TeamGameStat.fromJson(json["teamGameStatTwo"]),
        victorId: json["victorId"],
        homeTeamId: json["homeTeamId"],
        venue: json["venue"],
        highlights: json["highlights"],
      );

  Map<String, dynamic> toJson() => {
        "gameId": gameId,
        "teamGameStatOne": teamGameStatOne.toJson(),
        "teamGameStatTwo": teamGameStatTwo.toJson(),
        "victorId": victorId,
        "homeTeamId": homeTeamId,
        "venue": venue,
        "highlights": highlights,
      };
}

class TeamGameStat {
  TeamGameStat({
    required this.goalsAttempted,
    required this.goalsScored,
  });

  int goalsAttempted;
  int goalsScored;

  factory TeamGameStat.fromRawJson(String str) =>
      TeamGameStat.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamGameStat.fromJson(Map<String, dynamic> json) => TeamGameStat(
        goalsAttempted: json["goalsAttempted"],
        goalsScored: json["goalsScored"],
      );

  Map<String, dynamic> toJson() => {
        "goalsAttempted": goalsAttempted,
        "goalsScored": goalsScored,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }

  Map<T, String> get reverse {
    return reverseMap;
  }
}
