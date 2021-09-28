import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tournament_app/models/all.dart';
import 'package:tuple/tuple.dart';

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

/// Loads all the playoff data from the JSON in the assets folder
/// Returns [List<PlayoffSeason>] if asset found, else throws exception
Future<List<PlayoffSeason>> loadAllPlayoffData() async {
  String jsonData = await rootBundle.loadString('assets/data/playoffData.json');
  Map<String, dynamic> jsonMap = json.decode(jsonData);
  List<dynamic> data = jsonMap["output"];
  List<PlayoffSeason> output = [];
  for (var value in data) {
    output.add(PlayoffSeason.fromJson(value as Map<String, dynamic>));
  }
  return output;
}

/// Takes four [String] strA, strB, strC, strD and returns true if
/// one of {strA, strB} equals {strC, strD}
bool atLeastOneStringPairMatch(
    String strA, String strB, String strC, String strD) {
  return (strA == strC) || (strA == strD) || (strB == strC) || (strB == strD);
}

/// Takes four [int] intA, intB, intC, intD and returns true if
/// one of {intA, intB} equals {intC, intD}
bool atLeastOneIntPairMatch(int intA, int intB, int intC, int intD) {
  return (intA == intC) || (intA == intD) || (intB == intC) || (intB == intD);
}

/// Takes a [String] of the form "XXX v. YYY" or "XXX vs. YYY" and returns
/// "XXX @ YYY" if the [bool] homeTeamIsFirst = true, and "YYY @ XXX" otherwise
String toAwayAtHomeString(String input, bool homeTeamIsFirst) {
  String temp = consistentVersus(input);
  if (homeTeamIsFirst) {
    return temp.replaceAll("vs.", "@");
  } else {
    String home = temp.substring(0, 3);
    String away = temp.substring(8);
    return away + " @ " + home;
  }
}
