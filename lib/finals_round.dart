// NOTE: Parts of this file were generated using quicktype.io
//        Quicktype is a useful tool to generate classes in various languages
//        from JSON files. I wrote most of this file though!
///////////////////////////////////////////////////////////////////////////////
// To parse this JSON data, do
//
//     final playoffRound = playoffRoundFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

PlayoffsRound playoffRoundFromJson(String str) =>
    PlayoffsRound.fromJson(json.decode(str));

String playoffRoundToJson(PlayoffsRound data) => json.encode(data.toJson());

class PlayoffsRound {
  PlayoffsRound({
    required this.data,
    required this.total,
  });

  final List<Match> data; // retrieved from Json
  final int total; // retrieved from Json
  List<Series> series = []; // generated after Json retrieved

  factory PlayoffsRound.fromJson(Map<String, dynamic> json) {
    PlayoffsRound playoffsRound = PlayoffsRound(
      data: List<Match>.from(json["data"].map((x) => Match.fromJson(x))),
      total: json["total"],
    );
    return playoffsRound;
  }

  Map<String, dynamic> toJson() =>
      {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "total": total,
      };


  /// This static create() function is needed because we need to do async calls
  ///   to grab match data and generate
  static Future<Series> create() async {
    var component = Series(
        topSeedTeamId: 0,
        bottomSeedTeamId: 0,
        topSeedScore: 0,
        bottomSeedScore: 0,
        topSeedDidWin: false);

    // Do initialization that requires async
    //await component._complexAsyncInit();



    // Return the fully initialized object
    return component;
  }
}

// This is a class that is not a part of any API
// TODO: FINISH NOTEEE hedging
class Series {
  Series({
    required this.topSeedTeamId,
    required this.bottomSeedTeamId,
    required this.topSeedScore,
    required this.bottomSeedScore,
    required this.topSeedDidWin,
  });

  int topSeedTeamId;
  int bottomSeedTeamId;
  int topSeedScore;
  int bottomSeedScore;
  bool topSeedDidWin; // if this var is false, that means the bottom seed won
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

  factory Match.fromJson(Map<String, dynamic> json) =>
      Match(
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

  Map<String, dynamic> toJson() =>
      {
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


/// Returns a string representing the name of the given [round].
///
/// Throws an [ArgumentError] if [round] is not an integer between 1 and 4
String nameOfRound(int round) {
  switch (round) {
    case 1:
      return "Conference Quarterfinals";
    case 2:
      return "Conference Semifinals";
    case 3:
      return "Conference Finals";
    case 4:
      return "Stanley Cup Final";
    default:
      throw ArgumentError("round must be an int between 1 and 4!");
  }
}
