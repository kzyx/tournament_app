# tournament_app
#### A Flutter app that allows you to look at historical NHL Playoffs.
###### *Work on this project began on Sept 8, 2021*
###### *Page last updated Sept 10, 2021*
---
## Demo
Adding habit screen        |  Navigating habit list
:-------------------------:|:-------------------------:
![](http://g.recordit.co/8OQMVvc6T5.gif)    |   ![](http://g.recordit.co/A3jacBz8kG.gif)
---
 # Features
 ## Requirements
 Build a tournament control (i.e. playoff bracket) app written in Flutter that satisfies the following:
- [x] has at least 5 rounds
- [x] initializes in round 3
- [x] displays playoff data from the 2019 NHL Playoffs
- [x] has icons
- [x] is representative of the actual NHL playoffs
- [x] is NOT ugly
## Summary
I went a little beyond the requirements. This app uses the [statsapi.web.nhl.com](https://gitlab.com/dword4/nhlapi/-/blob/master/stats-api.md) API in order to retrieve playoff data for the desired season. Currently, only seasons 2013-2014 through 2018-2019 are supported (there are inconsistencies in the API JSON objects for older seasons that mean that I need to do more work before earlier seasons will be supported). The main value of this is that my solution is fairly scalable and portable. If I want to add more features (e.g. additional information about each of the seven games when tapping a playoff series), I can easily do this, as the API provides me with a 'Game ID' that I can employ to retrieve information about each game (three stars, names of players who scored, etc). Also, my solution is portable, as I could switch to an NBA API without too much effort.

---
# Installation
Simply download the repo, run `flutter run` in cmd/terminal and you should be good to go.

---
## Libraries/Tools used
- [GraphView](https://pub.dev/packages/graphview) for displaying the playoff bracket tree
---
#### Random
- Accidentally had a `final` keyword in the wrong place and ended up wasting an hour wondering why the state wasn't updating... LOL.
