import 'dart:convert';

/// Represents a single game played in the playoffs.
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

/// Represents the stats of a single team in a single game of the playoffs.
class TeamGameStat {
  TeamGameStat({
    required this.goalsAttempted,
    required this.goalsScored,
    required this.penaltyMin,
    required this.powerPlayPercentage,
    required this.powerPlayGoals,
    required this.blocked,
    required this.takeaways,
    required this.giveaways,
    required this.hits,
  });

  int goalsAttempted;
  int goalsScored;
  int penaltyMin;
  double powerPlayPercentage;
  int powerPlayGoals;
  int blocked;
  int takeaways;
  int giveaways;
  int hits;

  factory TeamGameStat.fromRawJson(String str) =>
      TeamGameStat.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamGameStat.fromJson(Map<String, dynamic> json) => TeamGameStat(
        goalsAttempted: json["goalsAttempted"],
        goalsScored: json["goalsScored"],
        penaltyMin: json["penaltyMin"],
        powerPlayPercentage: json["powerPlayPercentage"],
        powerPlayGoals: json["powerPlayGoals"],
        blocked: json["blocked"],
        takeaways: json["takeaways"],
        giveaways: json["giveaways"],
        hits: json["hits"],
      );

  Map<String, dynamic> toJson() => {
        "goalsAttempted": goalsAttempted,
        "goalsScored": goalsScored,
        "penaltyMin": penaltyMin,
        "powerPlayPercentage": powerPlayPercentage,
        "powerPlayGoals": powerPlayGoals,
        "blocked": blocked,
        "takeaways": takeaways,
        "giveaways": giveaways,
        "hits": hits,
      };
}
