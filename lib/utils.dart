import 'dart:core';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tournament_app/models/all.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/exceptions.dart';

/// Loads all the playoff data from the JSON in the assets folder
/// Returns [List<PlayoffSeason>] if asset found, else throws exception
Future<List<PlayoffSeason>> loadAllPlayoffData() async {
    String jsonData = await rootBundle.loadString(
        'assets/data/playoffData.json');
    Map<String, dynamic> jsonMap = json.decode(jsonData);
    List<dynamic> data = jsonMap["output"];
    List<PlayoffSeason> output = [];
    for (var value in data) {
      output.add(PlayoffSeason.fromJson(value as Map<String, dynamic>));
    }
    return output;
}

/// Takes a [String] of the form "XXX vs. YYY" and returns
/// "XXX @ YYY" if the [bool] homeTeamIsFirst = true, and "YYY @ XXX" otherwise.
/// Throws [InvalidInputException] if input string found to be invalid
String toAwayAtHomeString(String input, bool homeTeamIsFirst) {
  if (input.contains(" vs. ")) {
    if (homeTeamIsFirst) {
      return input.replaceAll(" vs. ", " @ ");
    } else {
      List<String> splitList = input.split(" vs. ");
      if (splitList.length != 2 || splitList[0].isEmpty || splitList[1].isEmpty) {
        throw InvalidInputException("");
      }
      return splitList[1] + " @ " + splitList[0];
    }
  } else {
    throw InvalidInputException("");
  }
}

/// This function generates a graph out of the given [PlayoffSeason].
/// Algorithm: It uses the last round to find the tree root. The two subtrees
/// are found by using the Eastern and Western conference member variables of
/// the series. In subsequent rounds, the subtrees are identified by finding
/// the series where one of the teamIDs matches the parent's teamID.
/// Throws [InvalidInputException] if not exactly 15 series in [PlayoffSeason]
Graph generatePlayoffGraph(PlayoffSeason playoffSeason) {
  // First ensure input is valid
  int numberOfNodes = 0;
  for (Round r in playoffSeason.rounds) {
    numberOfNodes += r.seriesList.length;
  }
  if (numberOfNodes != 15) {
    throw InvalidInputException("PlayoffSeason has $numberOfNodes != 15 nodes");
  }

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
  int idxW1 = playoffSeason.indexWhereSeriesMatches(2, rootW.series.teamOne);
  int idxW2 = playoffSeason.indexWhereSeriesMatches(2, rootW.series.teamTwo);
  int idxE1 = playoffSeason.indexWhereSeriesMatches(2, rootE.series.teamOne);
  int idxE2 = playoffSeason.indexWhereSeriesMatches(2, rootE.series.teamTwo);
  Series seriesWest1 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxW1];
  Series seriesWest2 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxW2];
  Series seriesEast1 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxE1];
  Series seriesEast2 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 2)
      .seriesList[idxE2];
  PlayoffNode rootW1 = PlayoffNode(id: 4, series: seriesWest1, roundNum: 2);
  PlayoffNode rootW2 = PlayoffNode(id: 5, series: seriesWest2, roundNum: 2);
  PlayoffNode rootE1 = PlayoffNode(id: 6, series: seriesEast1, roundNum: 2);
  PlayoffNode rootE2 = PlayoffNode(id: 7, series: seriesEast2, roundNum: 2);

  // Conference Quarterfinals (8 series) //////////////
  // Find the next elements of the tree by looking for the series in round 1
  // with matching team names
  int idxW11 = playoffSeason.indexWhereSeriesMatches(1, rootW1.series.teamOne);
  int idxW12 = playoffSeason.indexWhereSeriesMatches(1, rootW1.series.teamTwo);
  int idxW21 = playoffSeason.indexWhereSeriesMatches(1, rootW2.series.teamOne);
  int idxW22 = playoffSeason.indexWhereSeriesMatches(1, rootW2.series.teamTwo);
  int idxE11 = playoffSeason.indexWhereSeriesMatches(1, rootE1.series.teamOne);
  int idxE12 = playoffSeason.indexWhereSeriesMatches(1, rootE1.series.teamTwo);
  int idxE21 = playoffSeason.indexWhereSeriesMatches(1, rootE2.series.teamOne);
  int idxE22 = playoffSeason.indexWhereSeriesMatches(1, rootE2.series.teamTwo);
  Series seriesWest11 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxW11];
  Series seriesWest12 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxW12];
  Series seriesWest21 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxW21];
  Series seriesWest22 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxW22];
  Series seriesEast11 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxE11];
  Series seriesEast12 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxE12];
  Series seriesEast21 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxE21];
  Series seriesEast22 = playoffSeason.rounds
      .firstWhere((r) => r.roundNum == 1)
      .seriesList[idxE22];
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

  // Generate graph and draw edges between nodes to generate tree
  Graph graph = Graph();
  Paint paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;
  graph.addEdge(root, rootW, paint: paint);
  graph.addEdge(root, rootE, paint: paint);
  graph.addEdge(rootW, rootW1, paint: paint);
  graph.addEdge(rootW, rootW2, paint: paint);
  graph.addEdge(rootE, rootE1, paint: paint);
  graph.addEdge(rootE, rootE2, paint: paint);

  graph.addEdge(rootW1, rootWChild1Child1, paint: paint);
  graph.addEdge(rootW1, rootWChild1Child2, paint: paint);
  graph.addEdge(rootW2, rootWChild2Child1, paint: paint);
  graph.addEdge(rootW2, rootWChild2Child2, paint: paint);

  graph.addEdge(rootE1, rootEChild1Child1, paint: paint);
  graph.addEdge(rootE1, rootEChild1Child2, paint: paint);
  graph.addEdge(rootE2, rootEChild2Child1, paint: paint);
  graph.addEdge(rootE2, rootEChild2Child2, paint: paint);

  return graph;
}
