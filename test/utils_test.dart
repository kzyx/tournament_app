/// This file contains tests for the utils.dart file
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/utils.dart' as utils;
import 'package:tournament_app/exceptions.dart';
import 'package:graphview/GraphView.dart';

void main() {
  setUpAll(() {
    // Needed to make sure that rootBundle call in loadPlayoffData doesn't fail
    // during testing
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  // Test loadPlayoffData function
  test('loadPlayoffData() loads playoffs, which has >= 1 seasons', () async {
    expect((await utils.loadAllPlayoffData()).length, greaterThanOrEqualTo(1));
  });

  // Test toAwayAtHomeString function
  test('toAwayAtHomeString() works for valid input, switchOrder = true', () {
    expect(utils.toAwayAtHomeString("TEAM1 vs. TEAM2", true), "TEAM1 @ TEAM2");
  });
  test('toAwayAtHomeString() works for valid input, switchOrder = false', () {
    expect(utils.toAwayAtHomeString("TEAM1 vs. TEAM2", false), "TEAM2 @ TEAM1");
  });
  test('toAwayAtHomeString() throws error for invalid input', () {
    expect(() => utils.toAwayAtHomeString("TEAM1 v TEAM2", false),
        throwsA(isA<InvalidInputException>()));
  });
  test('toAwayAtHomeString() throws error for invalid input', () {
    expect(() => utils.toAwayAtHomeString("TEAM1 vs. ", false),
        throwsA(isA<InvalidInputException>()));
  });

  // Test generatePlayoffGraph function
  test('generatePlayoffGraph() throws error for 13, 16 nodes', () async {
    List<PlayoffSeason> playoffs = await utils.loadAllPlayoffData();
    playoffs.last.rounds[0].seriesList
        .add(playoffs.last.rounds[0].seriesList.last);
    expect(() => utils.generatePlayoffGraph(playoffs.last),
        throwsA(isA<InvalidInputException>()));
    playoffs.last.rounds[0].seriesList.removeLast();
    playoffs.last.rounds[0].seriesList.removeLast();
    expect(() => utils.generatePlayoffGraph(playoffs.last),
        throwsA(isA<InvalidInputException>()));
  });
  test(
      'generatePlayoffGraph() creates 15 vertex, 14 edge graph for valid input',
      () async {
    List<PlayoffSeason> playoffs = await utils.loadAllPlayoffData();
    Graph graph = utils.generatePlayoffGraph(playoffs.last);
    expect(graph.edges.length, 14);
    expect(graph.nodeCount(), 15);
  });
}
