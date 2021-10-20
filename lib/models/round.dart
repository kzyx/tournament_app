import 'package:tournament_app/models/series.dart';
import 'dart:convert';
import 'package:tournament_app/models/enum.dart';

/// Represents a single round in a playoff season (e.g. Conf. Semifinals)
class Round {
  Round({
    required this.roundNum,
    required this.roundName,
    required this.seriesList,
  });

  int roundNum;
  ConfName roundName;
  List<Series> seriesList;

  factory Round.fromRawJson(String str) => Round.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        roundNum: json["roundNum"],
        roundName: confNameValues.map[json["roundName"]]!,
        seriesList: List<Series>.from(
            json["seriesList"].map((x) => Series.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "roundNum": roundNum,
        "roundName": confNameValues.reverse[roundName],
        "seriesList": List<dynamic>.from(seriesList.map((x) => x.toJson())),
      };
}

enum ConfName {
  CONFERENCE_QUARTERFINALS,
  CONFERENCE_SEMIFINALS,
  CONFERENCE_FINALS,
  STANLEY_CUP_FINALS
}

final confNameValues = EnumValues({
  "Conference Finals": ConfName.CONFERENCE_FINALS,
  "Conference Quarterfinals": ConfName.CONFERENCE_QUARTERFINALS,
  "Conference Semifinals": ConfName.CONFERENCE_SEMIFINALS,
  "Stanley Cup Finals": ConfName.STANLEY_CUP_FINALS
});
