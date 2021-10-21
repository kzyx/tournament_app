# Information on each python script

## parse_create_json.py
This script generates the JSON that we use as a database for this project.
This JSON contains all of our playoff data.

### Installation
Ensure that you have [Python 3](https://www.python.org/downloads/) installed.
The `requests` and `marshmallow` packages must be installed.
You can run `pip install requests` and `pip install marshmallow` to install
these packages.

### Operation
This script is a little complicated, and this is mostly because of the fact
that the NHL Stats API is inconsistent. How, you ask? Examples include:
- Sometimes the `matchupName` key has value `DAL v VAN`, other times it may
have the value `DAL vs. VAN` or `DAL vs VAN`.
- Sometimes, when we make calls to the API endpoint to retrieve playoff data,
a team key in this JSON may have a null value for the `conference` key, which
causes issues for the generatePlayoffGraph() function, because it cannot find
the nodes it needs to build the graph (in a part of that algorithm it uses
the team conference in order to build the western and eastern conference
subtrees). This means we have to use another API endpoint to retrieve correct
information.
- Keys pertaining to stats such as faceoffWinPercentage aren't available if you
start going back to older seasons. For instance, blocked shots, hits, takeaways
are not available for seasons 2001 and before.
- etc

The rough idea is this: it first loads a playoffJSON object for a given season
using a `/tournaments/playoffs` endpoint. This object has data about the rounds
and series but not the individual games. For that playoffJSON object, it
iterates through every round and series, and uses a call to the 
`/teams` endpoint to find the team conference value for that season if it is
missing. Then, it uses another endpoint `/schedule` in order to obtain all the
gameIDs for the games played in the playoffs. Then, it uses 
`/game/<ID>/content` to retrieve highlights and `/game/<ID>/boxscore` to
retrieve game stats. This is saved in one JSON object with a tree structure.
Takes about 10 minutes to save a JSON for a dozen seasons.

### Output
This script saves a JSON object with the following structure at
 `assets/data/playoffData.json`.
```bash
└── Output: root of the tree
    │
    └── Season: represents a single playoff season 
        │       (e.g. 2019-2020 Playoffs)
        │
        └── Round: represents a single playoff round
            │      (e.g. 2019-2020 Western Conf. Finals)
            │
            └── Series: represents a single series 
                │       (e.g. DAL vs. VGK, Western Conf. Finals 2019-2020)
                │
                └── Game: represents a single game
                    │     (e.g. Game 5 of DAL vs. VGK, Western Conf. Finals 2019-2020)
                    │
                    └── TeamGameStat: represents the stats of a single team
                                      (e.g. DAL Game Stats [3 goals scored, 26 shots on goal,...]
                                       during Game 5 of DAL vs. VGK, Western Conf. Finals 2019-2020)
```

## icon_grabber_script.py
This script retrieves and saves `.png` files corresponding to the team logo
icon for each team in the NHL.

### Installation
Ensure that you have [Python 3](https://www.python.org/downloads/) installed.
For this file, you must first download [vips and 
pyvips](https://pypi.org/project/pyvips/), following the linked installation
instructions. Update the `os.environ['path']` variable before the 
`import pyvips` so that the path to the vips directory on your computer is
added as an environment variable. These packages are needed to convert
`.svg` files to `.png`.

### Operation
The script uses a source `https://www-league.nhlstatic.com/` to obtain logo
icons for each team in the NHL.
It basically tries different teamIDs from 0-100 for each the GET request, and
then  downloads the files. Then, it converts each image from `.svg` to `.png`.
The files are saved in the `assets/img` folder.
Note: Logos from icons historical teams such as the Quebec Nordiques and
20th century Winnipeg Jets are not available from this source.