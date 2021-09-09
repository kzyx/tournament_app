// To parse this JSON data, do
//
//     final playoffRound = playoffRoundFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'dart:convert';

class Playoffs {
  Playoffs({
    required this.copyright,
    required this.id,
    required this.name,
    required this.season,
    required this.defaultRound,
    required this.rounds,
  });

  final String copyright;
  final int id;
  final String name;
  final String season;
  final int defaultRound;
  final List<RoundElement> rounds;

  factory Playoffs.fromRawJson(String str) => Playoffs.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Playoffs.fromJson(Map<String, dynamic> json) => Playoffs(
    copyright: json["copyright"],
    id: json["id"],
    name: json["name"],
    season: json["season"],
    defaultRound: json["defaultRound"],
    rounds: List<RoundElement>.from(json["rounds"].map((x) => RoundElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "copyright": copyright,
    "id": id,
    "name": name,
    "season": season,
    "defaultRound": defaultRound,
    "rounds": List<dynamic>.from(rounds.map((x) => x.toJson())),
  };
}

class RoundElement {
  RoundElement({
    required this.number,
    required this.code,
    required this.names,
    required this.format,
    required this.seriesList,
  });

  final int number;
  final int code;
  final RoundNames names;
  final Format format;
  final List<Series> seriesList;

  factory RoundElement.fromRawJson(String str) => RoundElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoundElement.fromJson(Map<String, dynamic> json) => RoundElement(
    number: json["number"],
    code: json["code"],
    names: RoundNames.fromJson(json["names"]),
    format: Format.fromJson(json["format"]),
    seriesList: List<Series>.from(json["series"].map((x) => Series.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "code": code,
    "names": names.toJson(),
    "format": format.toJson(),
    "series": List<dynamic>.from(seriesList.map((x) => x.toJson())),
  };
}

class Format {
  Format({
    required this.name,
    required this.description,
    required this.numberOfGames,
    required this.numberOfWins,
  });

  final String name;
  final String description;
  final int numberOfGames;
  final int numberOfWins;

  factory Format.fromRawJson(String str) => Format.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Format.fromJson(Map<String, dynamic> json) => Format(
    name: json["name"],
    description: json["description"],
    numberOfGames: json["numberOfGames"],
    numberOfWins: json["numberOfWins"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "numberOfGames": numberOfGames,
    "numberOfWins": numberOfWins,
  };
}

class RoundNames {
  RoundNames({
    required this.name,
    required this.shortName,
  });

  final String name;
  final String shortName;

  factory RoundNames.fromRawJson(String str) => RoundNames.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoundNames.fromJson(Map<String, dynamic> json) => RoundNames(
    name: json["name"],
    shortName: json["shortName"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "shortName": shortName,
  };
}

class Series {
  Series({
    required this.seriesNumber,
    required this.seriesCode,
    required this.names,
    required this.currentGame,
    required this.conference,
    required this.round,
    required this.matchupTeams,
  });

  final int seriesNumber;
  final String seriesCode;
  final SeriesNames names;
  final CurrentGame currentGame;
  final Team conference;
  final SeriesRound round;
  final List<MatchupTeam> matchupTeams;

  factory Series.fromRawJson(String str) => Series.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Series.fromJson(Map<String, dynamic> json) => Series(
    seriesNumber: json["seriesNumber"],
    seriesCode: json["seriesCode"],
    names: SeriesNames.fromJson(json["names"]),
    currentGame: CurrentGame.fromJson(json["currentGame"]),
    conference: Team.fromJson(json["conference"]),
    round: SeriesRound.fromJson(json["round"]),
    matchupTeams: List<MatchupTeam>.from(json["matchupTeams"].map((x) => MatchupTeam.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "seriesNumber": seriesNumber,
    "seriesCode": seriesCode,
    "names": names.toJson(),
    "currentGame": currentGame.toJson(),
    "conference": conference.toJson(),
    "round": round.toJson(),
    "matchupTeams": List<dynamic>.from(matchupTeams.map((x) => x.toJson())),
  };
}

class Team {
  Team({
    required this.id,
    required this.name,
    required this.link,
  });

  int id;
  String name;
  String link;

  factory Team.fromRawJson(String str) => Team.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Team.fromJson(Map<String, dynamic> json) {
    var encoder = new JsonEncoder.withIndent("     ");
    debugPrint(encoder.convert(json));
    return Team(
      id: (json["int"] == null) ? 0 : json["int"],
      name: (json["name"] == null) ? " " : json["name"],
      link: (json["link"] == null) ? " " : json["link"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "link": link,
  };
}

class CurrentGame {
  CurrentGame({
    required this.seriesSummary,
  });

  final SeriesSummary seriesSummary;

  factory CurrentGame.fromRawJson(String str) => CurrentGame.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CurrentGame.fromJson(Map<String, dynamic> json) => CurrentGame(
    seriesSummary: SeriesSummary.fromJson(json["seriesSummary"]),
  );

  Map<String, dynamic> toJson() => {
    "seriesSummary": seriesSummary.toJson(),
  };
}

class SeriesSummary {
  SeriesSummary({
    required this.gamePk,
    required this.gameNumber,
    required this.gameLabel,
    required this.necessary,
    required this.gameCode,
    required this.gameTime,
    required this.seriesStatus,
    required this.seriesStatusShort,
  });

  final int gamePk;
  final int gameNumber;
  final String gameLabel;
  final bool necessary;
  final int gameCode;
  final DateTime gameTime;
  final String seriesStatus;
  final String seriesStatusShort;

  factory SeriesSummary.fromRawJson(String str) => SeriesSummary.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SeriesSummary.fromJson(Map<String, dynamic> json) => SeriesSummary(
    gamePk: json["gamePk"],
    gameNumber: json["gameNumber"],
    gameLabel: json["gameLabel"],
    necessary: json["necessary"],
    gameCode: json["gameCode"],
    gameTime: DateTime.parse(json["gameTime"]),
    seriesStatus: json["seriesStatus"],
    seriesStatusShort: json["seriesStatusShort"],
  );

  Map<String, dynamic> toJson() => {
    "gamePk": gamePk,
    "gameNumber": gameNumber,
    "gameLabel": gameLabel,
    "necessary": necessary,
    "gameCode": gameCode,
    "gameTime": gameTime.toIso8601String(),
    "seriesStatus": seriesStatus,
    "seriesStatusShort": seriesStatusShort,
  };
}

class MatchupTeam {
  MatchupTeam({
    required this.team,
    required this.seed,
    required this.seriesRecord,
  });

  final Team team;
  final Seed seed;
  final SeriesRecord seriesRecord;

  factory MatchupTeam.fromRawJson(String str) => MatchupTeam.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MatchupTeam.fromJson(Map<String, dynamic> json) => MatchupTeam(
    team: Team.fromJson(json["team"]),
    seed: Seed.fromJson(json["seed"]),
    seriesRecord: SeriesRecord.fromJson(json["seriesRecord"]),
  );

  Map<String, dynamic> toJson() => {
    "team": team.toJson(),
    "seed": seed.toJson(),
    "seriesRecord": seriesRecord.toJson(),
  };
}

class Seed {
  Seed({
    required this.type,
    required this.rank,
    required this.isTop,
  });

  final String type;
  final int rank;
  final bool isTop;

  factory Seed.fromRawJson(String str) => Seed.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Seed.fromJson(Map<String, dynamic> json) => Seed(
    type: json["type"],
    rank: json["rank"],
    isTop: json["isTop"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "rank": rank,
    "isTop": isTop,
  };
}

class SeriesRecord {
  SeriesRecord({
    required this.wins,
    required this.losses,
  });

  final int wins;
  final int losses;

  factory SeriesRecord.fromRawJson(String str) => SeriesRecord.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SeriesRecord.fromJson(Map<String, dynamic> json) => SeriesRecord(
    wins: json["wins"],
    losses: json["losses"],
  );

  Map<String, dynamic> toJson() => {
    "wins": wins,
    "losses": losses,
  };
}

class SeriesNames {
  SeriesNames({
    required this.matchupName,
    required this.matchupShortName,
    required this.teamAbbreviationA,
    required this.teamAbbreviationB,
    required this.seriesSlug,
  });

  final String matchupName;
  final String matchupShortName;
  final String teamAbbreviationA;
  final String teamAbbreviationB;
  final String seriesSlug;

  factory SeriesNames.fromRawJson(String str) => SeriesNames.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SeriesNames.fromJson(Map<String, dynamic> json) => SeriesNames(
    matchupName: json["matchupName"],
    matchupShortName: json["matchupShortName"],
    teamAbbreviationA: json["teamAbbreviationA"],
    teamAbbreviationB: json["teamAbbreviationB"],
    seriesSlug: json["seriesSlug"],
  );

  Map<String, dynamic> toJson() => {
    "matchupName": matchupName,
    "matchupShortName": matchupShortName,
    "teamAbbreviationA": teamAbbreviationA,
    "teamAbbreviationB": teamAbbreviationB,
    "seriesSlug": seriesSlug,
  };
}

class SeriesRound {
  SeriesRound({
    required this.number,
  });

  final int number;

  factory SeriesRound.fromRawJson(String str) => SeriesRound.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SeriesRound.fromJson(Map<String, dynamic> json) => SeriesRound(
    number: json["number"],
  );

  Map<String, dynamic> toJson() => {
    "number": number,
  };
}


//
// class Team {
//   Team({
//     required this.name,
//     required this.abbreviation,
//     required this.conference,
//     required this.id,
//     required this.franchiseId,
//   });
//
//   final int id;
//   final String name;
//   final String abbreviation;
//   final String conference;
//   final int franchiseId;
//
//   factory Team.fromJson(Map<String, dynamic> json) =>
//       Team(
//         id: json["id"],
//         name: json["name"],
//         abbreviation: json["abbreviation"],
//         conference: json["conference"]["name"],
//         franchiseId: json["franchiseId"],
//       );
//
//   Map<String, dynamic> toJson() =>
//       {
//         "id": id,
//         "name": name,
//         "abbreviation": abbreviation,
//         "conference": conference,
//         "franchiseId": franchiseId,
//       };
// }