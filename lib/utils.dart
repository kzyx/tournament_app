import 'package:flutter/material.dart';
import 'dart:core';
import 'playoff_series.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Takes a [String] with a single 'v' somewhere in it, and changes that to a
///   'vs.'. If the string already contains 'vs.', returns input string;
///   Throws [ArgumentError] if string doesn't contain exactly one 'v'.
///
/// We need this because the API is inconsistent and may return 'v' or 'vs'
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
          "vs." + string.substring(indexOfV + 1);
    }
  }
}


Future<Playoffs> fetchPlayoffs(int season) async {
  const baseUrl = 'https://statsapi.web.nhl.com/api/v1/tournaments/playoffs';
  const additionalUrl = '?expand=round.series,schedule.game.seriesSummary';
  final response =
  await http.get(Uri.parse(baseUrl + additionalUrl + '&season=$season'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    // List<dynamic> jsonList = jsonMap["rounds"];
    Playoffs playoffs = Playoffs.fromJson(jsonMap);
    return playoffs;
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load teams from statsapi.web.nhl.com');
  }
}
