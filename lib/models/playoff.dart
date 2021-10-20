import 'dart:convert';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/models/series.dart';
import 'package:tournament_app/models/round.dart';

/// Represents node in graph/tree generated using Playoffs object
class PlayoffNode extends Node {
  late Series series;
  late int roundNum;
  bool isVisible = true;

  PlayoffNode({required int id, required Series series, required int roundNum})
      : super.Id(id) {
    this.series = series;
    this.roundNum = roundNum;
  }
}

/// Represents all the data for a single playoff season (rounds, series, games)
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

  int getIndexOfMatchingSeries(int desiredRound, int desiredId) {
    int indexOfMatchingRound =
        rounds.indexWhere((r) => r.roundNum == desiredRound);
    return rounds[indexOfMatchingRound]
        .seriesList
        .indexWhere((s) => s.teamOne == desiredId || s.teamTwo == desiredId);
  }
}
