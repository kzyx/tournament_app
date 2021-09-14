import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:tournament_app/models/playoffs.dart';
import 'package:http/http.dart' as http;

/// Takes a [String] with a single 'v' somewhere in it, and changes that to a
/// 'vs.'. If the string already contains 'vs.', returns input string;
/// Throws [ArgumentError] if string doesn't contain exactly one 'v'.
///
/// Needed since the API is inconsistent and gives strings with 'v' or 'vs'.
String consistentVersus(String string) {
  int numberOfV = 'v'.allMatches(string).length;
  if (numberOfV == 0 || numberOfV >= 2) {
    throw ArgumentError("The stringing does not contain exactly one 'v'");
  } else {
    if (string.contains('vs')) {
      return string;
    } else {
      int indexOfV = string.indexOf('v');
      return string.substring(0, indexOfV) +
          "vs." +
          string.substring(indexOfV + 1);
    }
  }
}

/// Takes a season as an [int] of the form YEAR1YEAR2 (e.g. 20182019), and
/// makes a GET request to statsapi.web.nhl.com to get playoff data. Returns
///
/// Needed since the API is inconsistent and gives strings with 'v' or 'vs'.
Future<Playoffs> fetchPlayoffs(int season) async {
  const baseUrl = 'https://statsapi.web.nhl.com/api/v1/tournaments/playoffs';
  const additionalUrl = '?expand=round.series,schedule.game.seriesSummary';
  final response =
      await http.get(Uri.parse(baseUrl + additionalUrl + '&season=$season'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    Playoffs playoffs = Playoffs.fromJson(jsonMap);
    return playoffs;
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw HttpException('Failed to load teams from statsapi.web.nhl.com');
  }
}

/// Takes four [String] strA, strB, strC, strD and returns true if
/// one of {strA, strB} equals {strC, strD}
bool atLeastOneStringPairMatch(
    String strA, String strB, String strC, String strD) {
  return (strA == strC) || (strA == strD) || (strB == strC) || (strB == strD);
}
