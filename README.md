# tournament_app
#### A Flutter app that allows you to look at historical NHL Playoff data, including game stats, highlights, etc.
###### *Work on this project began on Sept 8, 2021.*
###### *The bulk of the work on this project was done between Sept 8-10, 2021.*
###### *A few new features (additional game data, video highlights, etc) were added Sept 21-27, 2021.*
###### *Page last updated Sept 27, 2021*
---
## Demo
<!-- ![](http://g.recordit.co/OekR28IPjU.gif) -->
<img src="demo.gif" width="400"/>

---
 # Features
- [x] User can browse playoff seasons 2009-2010 through 2018-2019
- [x] User can toggle the visibility of the different rounds (anywhere between 1 and all of the rounds visible)
- [x] For each playoff series, user can see all games, and game stats such as goals scored, shots on goal, and save percentage
- [x] When available, user can see extended highlights of each game in a series (not available for seasons 2013-2014 and earlier, as the NHL API was missing this data)
- [x] Fast loading speeds, as all playoff data, game data, and video links are saved on the actual device (preprocessed from NHL API and stored in a compact JSON)
- [x] Sleek material UI design

## Design summary
The initial version of this app queried the [statsapi.web.nhl.com](https://gitlab.com/dword4/nhlapi/-/blob/master/stats-api.md) API in order to retrieve playoff data for the desired season. There was about a ~2 second delay in loading a different playoff season. I wanted to query game data as well, but found that loading the desired data using queries would take several extra seconds (loading 7 games in a single series is tens of megabytes, as the server returns too much data and at least two different queries are needed to obtain game stats and highlights). I created a Python script that queries the NHL API and generates a JSON object with all the relevant information pre-loaded (game data including links to extended highlight videos, playoff data, etc). Generating this JSON takes about a minute per season. Then, this JSON is used by the app to display relevant playoff bracket data.

---
# Installation
To download on Android, simply check out the [current release](https://github.com/kzyx/tournament_app/releases/tag/v1.0.0).
Alternatively (this is actually the only choice for iOS), simply download the repo, and [install Flutter](https://flutter.dev/docs/get-started/install) if you don't already have it installed. Run `flutter run` in cmd/terminal, and you should be good to go!

---
# Libraries/Tools used
- [Chewie](https://pub.dev/packages/chewie) for displaying the extended video highlights
- [GraphView](https://pub.dev/packages/graphview) for displaying the playoff bracket tree
