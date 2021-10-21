import 'package:tournament_app/models/series.dart';
import 'dart:convert';
import 'package:tournament_app/models/enum.dart';

/// Represents a single round in a playoff season (e.g. Conf. Semifinals).
class Round {
  Round({
    required this.roundNum,
    required this.roundName,
    required this.seriesList,
  });

  int roundNum;
  RoundName roundName;
  List<Series> seriesList;

  factory Round.fromRawJson(String str) => Round.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Round.fromJson(Map<String, dynamic> json) => Round(
        roundNum: json["roundNum"],
        roundName: roundNames.map[json["roundName"]]!,
        seriesList: List<Series>.from(
            json["seriesList"].map((x) => Series.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "roundNum": roundNum,
        "roundName": roundNames.reverse[roundName],
        "seriesList": List<dynamic>.from(seriesList.map((x) => x.toJson())),
      };
}

/// Enumeration for Conference name.
enum RoundName {
  CONFERENCE_QUARTERFINALS,
  CONFERENCE_SEMIFINALS,
  CONFERENCE_FINALS,
  STANLEY_CUP_FINALS
}

final roundNames = EnumValues({
  "Conference Finals": RoundName.CONFERENCE_FINALS,
  "Conference Quarterfinals": RoundName.CONFERENCE_QUARTERFINALS,
  "Conference Semifinals": RoundName.CONFERENCE_SEMIFINALS,
  "Stanley Cup Finals": RoundName.STANLEY_CUP_FINALS
});
