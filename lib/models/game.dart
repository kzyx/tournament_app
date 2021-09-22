// To parse this JSON data, do
//
//     final playoffRound = playoffRoundFromJson(jsonString);

import 'dart:convert';

// class PlayoffMatchup {
//   PlayoffMatchup({
//     required this.copyright,
//     List<PlayoffSingleGame>
//   });
//
//   final String copyright;
//
// }
//
// class PlayoffSingleGame {
//   final int homeTeamId;
//   final int awayTeamId;
//   final int homeTeamName;
//   final int awayTeamName;
//   final int
// }

class PlayoffGames {
  PlayoffGames({
    required this.copyright,
    required this.totalItems,
    required this.totalEvents,
    required this.totalGames,
    required this.totalMatches,
    required this.metaData,
    required this.wait,
    required this.dates,
  });

  final String copyright;
  final int totalItems;
  final int totalEvents;
  final int totalGames;
  final int totalMatches;
  final MetaData metaData;
  final int wait;
  final List<Date> dates;

  factory PlayoffGames.fromRawJson(String str) => PlayoffGames.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PlayoffGames.fromJson(Map<String, dynamic> json) => PlayoffGames(
    copyright: json["copyright"],
    totalItems: json["totalItems"],
    totalEvents: json["totalEvents"],
    totalGames: json["totalGames"],
    totalMatches: json["totalMatches"],
    metaData: MetaData.fromJson(json["metaData"]),
    wait: json["wait"],
    dates: List<Date>.from(json["dates"].map((x) => Date.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "copyright": copyright,
    "totalItems": totalItems,
    "totalEvents": totalEvents,
    "totalGames": totalGames,
    "totalMatches": totalMatches,
    "metaData": metaData.toJson(),
    "wait": wait,
    "dates": List<dynamic>.from(dates.map((x) => x.toJson())),
  };
}

class Date {
  Date({
    required this.date,
    required this.totalItems,
    required this.totalEvents,
    required this.totalGames,
    required this.totalMatches,
    required this.games,
    required this.events,
    required this.matches,
  });

  final DateTime date;
  final int totalItems;
  final int totalEvents;
  final int totalGames;
  final int totalMatches;
  final List<Game> games;
  final List<dynamic> events;
  final List<dynamic> matches;

  factory Date.fromRawJson(String str) => Date.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Date.fromJson(Map<String, dynamic> json) => Date(
    date: DateTime.parse(json["date"]),
    totalItems: json["totalItems"],
    totalEvents: json["totalEvents"],
    totalGames: json["totalGames"],
    totalMatches: json["totalMatches"],
    games: List<Game>.from(json["games"].map((x) => Game.fromJson(x))),
    events: List<dynamic>.from(json["events"].map((x) => x)),
    matches: List<dynamic>.from(json["matches"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "totalItems": totalItems,
    "totalEvents": totalEvents,
    "totalGames": totalGames,
    "totalMatches": totalMatches,
    "games": List<dynamic>.from(games.map((x) => x.toJson())),
    "events": List<dynamic>.from(events.map((x) => x)),
    "matches": List<dynamic>.from(matches.map((x) => x)),
  };
}

class Game {
  Game({
    required this.gamePk,
    required this.link,
    required this.season,
    required this.gameDate,
    required this.status,
    required this.teams,
  });

  final int gamePk;
  final String link;
  final String season;
  final DateTime gameDate;
  final Status status;
  final Teams teams;

  factory Game.fromRawJson(String str) => Game.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    gamePk: json["gamePk"],
    link: json["link"],
    season: json["season"],
    gameDate: DateTime.parse(json["gameDate"]),
    status: Status.fromJson(json["status"]),
    teams: Teams.fromJson(json["teams"]),
  );

  Map<String, dynamic> toJson() => {
    "gamePk": gamePk,
    "link": link,
    "season": season,
    "gameDate": gameDate.toIso8601String(),
    "status": status.toJson(),
    "teams": teams.toJson(),
  };
}

class Status {
  Status({
    required this.codedGameState,
    required this.statusCode,
    required this.startTimeTbd,
  });

  final String codedGameState;
  final String statusCode;
  final bool startTimeTbd;

  factory Status.fromRawJson(String str) => Status.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Status.fromJson(Map<String, dynamic> json) => Status(
    codedGameState: json["codedGameState"],
    statusCode: json["statusCode"],
    startTimeTbd: json["startTimeTBD"],
  );

  Map<String, dynamic> toJson() => {
    "codedGameState": codedGameState,
    "statusCode": statusCode,
    "startTimeTBD": startTimeTbd,
  };
}

class Teams {
  Teams({
    required this.away,
    required this.home,
  });

  final Away away;
  final Away home;

  factory Teams.fromRawJson(String str) => Teams.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Teams.fromJson(Map<String, dynamic> json) => Teams(
    away: Away.fromJson(json["away"]),
    home: Away.fromJson(json["home"]),
  );

  Map<String, dynamic> toJson() => {
    "away": away.toJson(),
    "home": home.toJson(),
  };
}

class Away {
  Away({
    required this.leagueRecord,
    required this.score,
  });

  final LeagueRecord leagueRecord;
  final int score;

  factory Away.fromRawJson(String str) => Away.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Away.fromJson(Map<String, dynamic> json) => Away(
    leagueRecord: LeagueRecord.fromJson(json["leagueRecord"]),
    score: json["score"],
  );

  Map<String, dynamic> toJson() => {
    "leagueRecord": leagueRecord.toJson(),
    "score": score,
  };
}

class LeagueRecord {
  LeagueRecord({
    required this.wins,
    required this.losses,
  });

  final int wins;
  final int losses;

  factory LeagueRecord.fromRawJson(String str) => LeagueRecord.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeagueRecord.fromJson(Map<String, dynamic> json) => LeagueRecord(
    wins: json["wins"],
    losses: json["losses"],
  );

  Map<String, dynamic> toJson() => {
    "wins": wins,
    "losses": losses,
  };
}

class MetaData {
  MetaData({
    required this.timeStamp,
  });

  final String timeStamp;

  factory MetaData.fromRawJson(String str) => MetaData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MetaData.fromJson(Map<String, dynamic> json) => MetaData(
    timeStamp: json["timeStamp"],
  );

  Map<String, dynamic> toJson() => {
    "timeStamp": timeStamp,
  };
}
