// NOTE: This was partly generated using quicktype.io (I also wrote code)
// To parse this JSON data, do
//
//     final playoffRound = playoffRoundFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

PlayoffsRound playoffRoundFromJson(String str) => PlayoffsRound.fromJson(json.decode(str));

String playoffRoundToJson(PlayoffsRound data) => json.encode(data.toJson());

class PlayoffsRound {
  PlayoffsRound({
    required this.data,
    required this.total,
  });

  final List<Match> data;
  final int total;

  factory PlayoffsRound.fromJson(Map<String, dynamic> json) => PlayoffsRound(
    data: List<Match>.from(json["data"].map((x) => Match.fromJson(x))),
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "total": total,
  };
}

class Match {
  Match({
    required this.id,
    required this.bottomSeedWins,
    required this.gameId,
    required this.gameNumber,
    required this.gameTypeId,
    required this.gamesNeededToWin,
    required this.lengthOfSeries,
    required this.playoffRound,
    required this.playoffSeriesLetter,
    required this.seasonId,
    required this.seriesTitle,
    required this.topSeedWins,
  });

  final int id;
  final int bottomSeedWins;
  final int gameId;
  final int gameNumber;
  final int gameTypeId;
  final int gamesNeededToWin;
  final int lengthOfSeries;
  final int playoffRound;
  final String playoffSeriesLetter;
  final int seasonId;
  final String seriesTitle;
  final int topSeedWins;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: json["id"],
    bottomSeedWins: json["bottomSeedWins"],
    gameId: json["gameId"],
    gameNumber: json["gameNumber"],
    gameTypeId: json["gameTypeId"],
    gamesNeededToWin: json["gamesNeededToWin"],
    lengthOfSeries: json["lengthOfSeries"],
    playoffRound: json["playoffRound"],
    playoffSeriesLetter: json["playoffSeriesLetter"],
    seasonId: json["seasonId"],
    seriesTitle: json["seriesTitle"],
    topSeedWins: json["topSeedWins"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "bottomSeedWins": bottomSeedWins,
    "gameId": gameId,
    "gameNumber": gameNumber,
    "gameTypeId": gameTypeId,
    "gamesNeededToWin": gamesNeededToWin,
    "lengthOfSeries": lengthOfSeries,
    "playoffRound": playoffRound,
    "playoffSeriesLetter": playoffSeriesLetter,
    "seasonId": seasonId,
    "seriesTitle": seriesTitle,
    "topSeedWins": topSeedWins,
  };
}

class Team {
  Team({
    required this.name,
    required this.abbreviation,
    required this.conference,
    required this.id,
    required this.franchiseId,
  });

  final int id;
  final String name;
  final String abbreviation;
  final String conference;
  final int franchiseId;

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json["id"],
    name: json["name"],
    abbreviation: json["abbreviation"],
    conference: json["conference"]["name"],
    franchiseId: json["franchiseId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "abbreviation": abbreviation,
    "conference": conference,
    "franchiseId": franchiseId,
  };
}






/// Returns a string representing the name of the given [round].
///
/// Throws an [ArgumentError] if [round] is not an integer between 1 and 4
String nameOfRound(int round) {
  switch (round) {
    case 1: return "Conference Quarterfinals";
    case 2: return "Conference Semifinals";
    case 3: return "Conference Finals";
    case 4: return "Stanley Cup Final";
    default: throw ArgumentError("round must be an int between 1 and 4!");
  }
}