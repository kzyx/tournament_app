/// This file contains tests for widgets

import 'package:tournament_app/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tournament_app/widgets/dropdown.dart';
import 'package:tournament_app/widgets/series_popup.dart';
import 'package:tournament_app/widgets/video_player_popup.dart';
import 'package:tournament_app/models/all.dart';
import 'dart:math';

String sampleVideoBaseURL = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/";
String sampleVideoURL1 = sampleVideoBaseURL + "BigBuckBunny.mp4";
String sampleVideoURL2 = sampleVideoBaseURL + "ForBiggerEscapes.mp4";

void main() {
  testWidgets('Series popup has correct # of home/away games', (WidgetTester tester) async {
    const materialAppKey = Key("key1");
    const seriesPopupKey = Key("key2");

    await tester.pumpWidget(MaterialApp(key: materialAppKey,
      home: Material(
        child: SeriesPopup(key: seriesPopupKey, series: generateSeriesForTesting()),
      ),
    ));;

    expect(find.byKey(materialAppKey), findsOneWidget);
    expect(find.byKey(seriesPopupKey), findsOneWidget);

    // Ensure that we have an appropriate number of away and home games
    expect(find.text("TEAM1 @ TEAM2"), findsNWidgets(4));
    expect(find.text("TEAM2 @ TEAM1"), findsNWidgets(3));
  });
  testWidgets('Dropdown throws when empty options list given', (WidgetTester tester) async {
    const dropdownKey = Key("key2");

    List<int> emptyList = [];

    expect(PlayoffYearDropdown(key: dropdownKey,
        playoffYearNums: emptyList, updateCurrentSeason: (int a) => print(a)),
        throwsA(isA<InvalidInputException>()));
  });
  testWidgets('Dropdown opens when valid input given', (WidgetTester tester) async {
    const materialAppKey = Key("key1");
    const dropdownKey = Key("key2");

    List<int> list = [20172018, 20182019, 20192020];

    await tester.pumpWidget(MaterialApp(key: materialAppKey,
      home: Material(
        child: PlayoffYearDropdown(key: dropdownKey,
            playoffYearNums: list, updateCurrentSeason: (int a) => print(a)))
    ));

    expect(find.byKey(materialAppKey), findsOneWidget);
    expect(find.byKey(dropdownKey), findsOneWidget);
  });
  testWidgets('VideoPlayerPopup can open multiple videos', (WidgetTester tester) async {
    const materialAppKey = Key("key1");
    UniqueKey uniqueKey = UniqueKey();

    // Load widget the first time and search by key to find it
    await tester.pumpWidget(MaterialApp(key: materialAppKey,
      home: Material(
        child: VideoPlayerPopup(sampleVideoURL1, uniqueKey)),
    ));
    expect(find.byKey(materialAppKey), findsOneWidget);
    expect(find.byKey(uniqueKey), findsOneWidget);

    // Load widget the second time on another URL, ensure only one widget found
    await tester.pumpWidget(MaterialApp(key: materialAppKey,
      home: Material(
          child: VideoPlayerPopup(sampleVideoURL2, uniqueKey)),
    ));
    expect(find.byKey(materialAppKey), findsOneWidget);
    expect(find.byKey(uniqueKey), findsOneWidget);
  });
}

/// Returns a [Series] for testing purposes. Contents are partly random.
Series generateSeriesForTesting() {
  List<Game> gamesList = [];
  Random random = Random();
  for (int i = 0; i < 7; i++) {
    int teamOne = 5;
    int teamTwo = 7;
    int homeTeam = (i % 2 == 0) ? teamOne : teamTwo;
    int goalsScored1 = random.nextInt(50);
    int goalsScored2 = random.nextInt(50);
    TeamGameStat tgs1 = TeamGameStat(goalsAttempted: goalsScored1,
        goalsScored: goalsScored1 + random.nextInt(50),
        penaltyMin: 50,
        powerPlayPercentage: 25.0,
        powerPlayGoals: 10,
        blocked: 5,
        takeaways: 5,
        giveaways: 5,
        hits: 5);
    TeamGameStat tgs2 = TeamGameStat(goalsAttempted: goalsScored2,
        goalsScored: goalsScored2 + random.nextInt(50),
        penaltyMin: 25,
        powerPlayPercentage: 75.0,
        powerPlayGoals: 10,
        blocked: 5,
        takeaways: 5,
        giveaways: 5,
        hits: 5);
    gamesList.add(Game(gameId: i, teamGameStatOne: tgs1,
        teamGameStatTwo: tgs2, victorId: teamOne,
        homeTeamId: homeTeam, venue: "VENUE1",
        highlights: sampleVideoURL1));
  }
  Series series = Series(shortName: "TEAM1 vs. TEAM2",
      longName: "TEAM1 versus TEAM2",
      shortResult: "TEAM1 won 4-3",
      longResult: "TEAM1 (C1) defeated TEAM2 (A1) 5-0",
      teamOne: 5,
      teamTwo: 7,
      teamOneGamesWon: 4,
      teamTwoGamesWon: 3,
      conference: Conference.EASTERN,
      games: gamesList);
  return series;
}
