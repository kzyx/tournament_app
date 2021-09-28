# tournament_app
#### A Flutter app that allows you to look at historical NHL Playoffs.
###### *Work on this project began on Sept 8, 2021*
###### *Page last updated Sept 10, 2021*
---
## Demo
![](http://g.recordit.co/OekR28IPjU.gif)
---
 # Features
- [x] User can browse playoff seasons [2009-2010, ..., 2018-2019]
- [x] User can toggle the visibility of the different rounds (only round 1 visible, ..., all rounds visible)
- [x] For each playoff series, user can see all games, and game stats such as goals scored, shots on goal, and save percentage
- [x] When available, user can see extended highlights of each game in a series (not available for seasons 2013-2014 and earlier, as the NHL API is missing this data)
- [x] Fast loading speeds, as all playoff data, game data, and video links are saved on the actual device (preprocessed and stored in a compact 300kB JSON)
- [x] Sleek material UI design
## Summary
I went a little beyond the requirements. This app uses the [statsapi.web.nhl.com](https://gitlab.com/dword4/nhlapi/-/blob/master/stats-api.md) API in order to retrieve playoff data for the desired season. Currently, only seasons 2013-2014 through 2018-2019 are supported (there are inconsistencies in the API JSON objects for older seasons that mean that I need to do more work before earlier seasons will be supported). The main value in using the API is that my solution is fairly scalable and portable. If I want to add more features (e.g. additional information about each of the seven games when tapping a playoff series), I can easily do this, as the API provides me with a 'Game ID' that I can employ to retrieve information about each game (three stars, names of players who scored, etc). Also, my solution is portable, as I could switch to an NBA API without too much effort.

---
# Installation
Simply download the repo, run `flutter run` in cmd/terminal and you should be good to go.

---
# Libraries/Tools used
- [GraphView](https://pub.dev/packages/graphview) for displaying the playoff bracket tree
---
