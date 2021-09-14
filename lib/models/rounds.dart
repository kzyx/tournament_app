// This file was partly generated by quicktype.io (gets classes from JSON)
// I wrote a lot of the code though. Essentially, the JSON object retrieved
// from the GET request is turned into a Playoffs object. The PlayoffNode
// represents a node in the graph/tree generated from the Playoffs object.

import 'dart:convert';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/models/series.dart';

/// Represents a single round of the playoffs (e.g. Conference Finals)
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
  final RoundFormat format;
  final List<Series> seriesList;

  factory RoundElement.fromRawJson(String str) =>
      RoundElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoundElement.fromJson(Map<String, dynamic> json) => RoundElement(
        number: json["number"],
        code: json["code"],
        names: RoundNames.fromJson(json["names"]),
        format: RoundFormat.fromJson(json["format"]),
        seriesList:
            List<Series>.from(json["series"].map((x) => Series.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "code": code,
        "names": names.toJson(),
        "format": format.toJson(),
        "series": List<dynamic>.from(seriesList.map((x) => x.toJson())),
      };
}

/// Represents round format (e.g. best of 7 series, etc)
class RoundFormat {
  RoundFormat({
    required this.name,
    required this.description,
    required this.numberOfGames,
    required this.numberOfWins,
  });

  final String name;
  final String description;
  final int numberOfGames;
  final int numberOfWins;

  factory RoundFormat.fromRawJson(String str) =>
      RoundFormat.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoundFormat.fromJson(Map<String, dynamic> json) => RoundFormat(
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

/// Represents round name (e.g. Boston Bruins vs. Vancouver Canucks)
class RoundNames {
  RoundNames({
    required this.name,
    required this.shortName,
  });

  final String name;
  final String shortName;

  factory RoundNames.fromRawJson(String str) =>
      RoundNames.fromJson(json.decode(str));

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