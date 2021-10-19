// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tournament_app/main.dart';
import 'package:tournament_app/series_popup.dart';
import 'package:tournament_app/video_player_popup.dart';
import 'package:tournament_app/models/all.dart';
import 'dart:math';

void main() {
  testWidgets('Series popup not crashing', (WidgetTester tester) async {
    const materialAppKey = Key("key1");
    const seriesPopupKey = Key("key2");

    await tester.pumpWidget(MaterialApp(key: materialAppKey,
      home: Material(
        child: SeriesPopup(key: seriesPopupKey, series: getRandomSeriesForTesting()),
      ),
    ));;

    expect(find.byKey(materialAppKey), findsOneWidget);
    expect(find.byKey(seriesPopupKey), findsOneWidget);
  });
  testWidgets('Video player not crashing', (WidgetTester tester) async {
    const materialAppKey = Key("key1");
    UniqueKey uniqueKey = UniqueKey();

    await tester.pumpWidget(MaterialApp(key: materialAppKey,
      home: Material(
        child: VideoPlayerPopup("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", uniqueKey)),
    ));

    expect(find.byKey(materialAppKey), findsOneWidget);
    expect(find.byKey(uniqueKey), findsOneWidget);
  });
}

Series getRandomSeriesForTesting() {
  List<Game> gamesList = [];
  Random random = Random();
  for (int i = 0; i < 7; i++) {
    int teamOne = 5;
    int teamTwo = 7;
    int homeTeam = (random.nextInt(2) == 1) ? teamOne : teamTwo;
    int goalsScored1 = random.nextInt(50);
    int goalsScored2 = random.nextInt(50);
    TeamGameStat tgs1 = TeamGameStat(goalsAttempted: goalsScored1, goalsScored: goalsScored1 + random.nextInt(50));
    TeamGameStat tgs2 = TeamGameStat(goalsAttempted: goalsScored2, goalsScored: goalsScored2 + random.nextInt(50));
    gamesList.add(new Game(gameId: i, teamGameStatOne: tgs1,
        teamGameStatTwo: tgs2, victorId: teamOne,
        homeTeamId: homeTeam, venue: "VENUE1",
        highlights: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"));
  }
  Series series = Series(shortName: "TEAM1 vs. TEAM2",
      longName: "TEAM1 vs. TEAM2",
      shortResult: "TEAM1 vs. TEAM2",
      longResult: "TEAM1 vs. TEAM2",
      teamOne: 5,
      teamTwo: 7,
      teamOneGamesWon: 4,
      teamTwoGamesWon: 3,
      conference: Conference.EASTERN,
      games: gamesList);
  return series;
}