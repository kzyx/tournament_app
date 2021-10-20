import 'dart:core';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tournament_app/models/all.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

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

/// Takes a [String] of the form "XXX vs. YYY" and returns
/// "XXX @ YYY" if the [bool] homeTeamIsFirst = true, and "YYY @ XXX" otherwise
String toAwayAtHomeString(String input, bool homeTeamIsFirst) {
  if (homeTeamIsFirst) {
    return input.replaceAll("vs.", "@");
  } else {
    String home = input.substring(0, 3);
    String away = input.substring(8);
    return away + " @ " + home;
  }
}

/// This function generates a graph out of the given [PlayoffSeason].
/// Algorithm: It uses the last round to find the tree root. The two subtrees
/// are found by using the Eastern and Western conference member variables of
/// the series. In subsequent rounds, the subtrees are identified by finding
/// the series where one of the teamIDs matches the parent's teamID.
Graph generatePlayoffGraph(PlayoffSeason playoffSeason) {
  // Async fetch both list of games and playoff bracket data
  // Await the playoff bracket data since that is essential for the graph

  // In the below code, we generate nodes for each playoff series
  // Stanley Cup Finals (1 series) ////////////////////
  Series series =
      playoffSeason.rounds.firstWhere((r) => (r.roundNum == 4)).seriesList[0];
  PlayoffNode root = PlayoffNode(id: 1, series: series, roundNum: 4);

  // Conference Finals (2 series) /////////////////////
  List<Series> seriesList =
      playoffSeason.rounds.firstWhere((r) => (r.roundNum == 3)).seriesList;
  PlayoffNode rootW = PlayoffNode(
      id: 2,
      series: seriesList.firstWhere((s) => s.conference == Conference.WESTERN),
      roundNum: 3);
  PlayoffNode rootE = PlayoffNode(
      id: 3,
      series: seriesList.firstWhere((s) => s.conference == Conference.EASTERN),
      roundNum: 3);

  // Conference Semifinals (4 series) /////////////////
  int idxWest1 = playoffSeason.getIndexOfMatchingSeries(2, rootW.series.teamOne);
  int idxWest2 = playoffSeason.getIndexOfMatchingSeries(2, rootW.series.teamTwo);
  int idxEast1 = playoffSeason.getIndexOfMatchingSeries(2, rootE.series.teamOne);
  int idxEast2 = playoffSeason.getIndexOfMatchingSeries(2, rootE.series.teamTwo);
  Series seriesWest1 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxWest1];
  Series seriesWest2 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxWest2];
  Series seriesEast1 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxEast1];
  Series seriesEast2 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxEast2];
  PlayoffNode rootWChild1 = PlayoffNode(id: 4, series: seriesWest1, roundNum: 2);
  PlayoffNode rootWChild2 = PlayoffNode(id: 5, series: seriesWest2, roundNum: 2);
  PlayoffNode rootEChild1 = PlayoffNode(id: 6, series: seriesEast1, roundNum: 2);
  PlayoffNode rootEChild2 = PlayoffNode(id: 7, series: seriesEast2, roundNum: 2);

  // Conference Quarterfinals (8 series) //////////////
  // Find the next elements of the tree by looking for the series in round 1
  // with matching team names
  int idxWestest11 =
      playoffSeason.getIndexOfMatchingSeries(1, rootWChild1.series.teamOne);
  int idxWest12 =
      playoffSeason.getIndexOfMatchingSeries(1, rootWChild1.series.teamTwo);
  int idxWest21 =
      playoffSeason.getIndexOfMatchingSeries(1, rootWChild2.series.teamOne);
  int idxWest22 =
      playoffSeason.getIndexOfMatchingSeries(1, rootWChild2.series.teamTwo);
  int idxEast11 =
      playoffSeason.getIndexOfMatchingSeries(1, rootEChild1.series.teamOne);
  int idxEast12 =
      playoffSeason.getIndexOfMatchingSeries(1, rootEChild1.series.teamTwo);
  int idxEast21 =
      playoffSeason.getIndexOfMatchingSeries(1, rootEChild2.series.teamOne);
  int idxEast22 =
      playoffSeason.getIndexOfMatchingSeries(1, rootEChild2.series.teamTwo);
  Series seriesWest11 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxWestest11];
  Series seriesWest12 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxWest12];
  Series seriesWest21 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxWest21];
  Series seriesWest22 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxWest22];
  Series seriesEast11 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxEast11];
  Series seriesEast12 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxEast12];
  Series seriesEast21 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxEast21];
  Series seriesEast22 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxEast22];
  PlayoffNode rootWChild1Child1 =
      PlayoffNode(id: 8, series: seriesWest11, roundNum: 1);
  PlayoffNode rootWChild1Child2 =
      PlayoffNode(id: 9, series: seriesWest12, roundNum: 1);
  PlayoffNode rootWChild2Child1 =
      PlayoffNode(id: 10, series: seriesWest21, roundNum: 1);
  PlayoffNode rootWChild2Child2 =
      PlayoffNode(id: 11, series: seriesWest22, roundNum: 1);
  PlayoffNode rootEChild1Child1 =
      PlayoffNode(id: 12, series: seriesEast11, roundNum: 1);
  PlayoffNode rootEChild1Child2 =
      PlayoffNode(id: 13, series: seriesEast12, roundNum: 1);
  PlayoffNode rootEChild2Child1 =
      PlayoffNode(id: 14, series: seriesEast21, roundNum: 1);
  PlayoffNode rootEChild2Child2 =
      PlayoffNode(id: 15, series: seriesEast22, roundNum: 1);

  // In the below code, we generate a new graph, storing in _graph
  Graph graph = Graph();
  Paint paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;
  graph.addEdge(root, rootW, paint: paint);
  graph.addEdge(root, rootE, paint: paint);
  graph.addEdge(rootW, rootWChild1, paint: paint);
  graph.addEdge(rootW, rootWChild2, paint: paint);
  graph.addEdge(rootE, rootEChild1, paint: paint);
  graph.addEdge(rootE, rootEChild2, paint: paint);

  graph.addEdge(rootWChild1, rootWChild1Child1, paint: paint);
  graph.addEdge(rootWChild1, rootWChild1Child2, paint: paint);
  graph.addEdge(rootWChild2, rootWChild2Child1, paint: paint);
  graph.addEdge(rootWChild2, rootWChild2Child2, paint: paint);

  graph.addEdge(rootEChild1, rootEChild1Child1, paint: paint);
  graph.addEdge(rootEChild1, rootEChild1Child2, paint: paint);
  graph.addEdge(rootEChild2, rootEChild2Child1, paint: paint);
  graph.addEdge(rootEChild2, rootEChild2Child2, paint: paint);

  return graph;
}

/// Returns list of all the playoff year numbers in _playoffs
List<int> getAllPlayoffYearNumbers(List<PlayoffSeason> playoffs) {
  List<int> output = [];
  for (int i = 0; i < playoffs.length; i++) {
    output.add(playoffs[i].seasonNum);
  }
  output.sort((int a, int b) => a.compareTo(b));
  return output;
}
