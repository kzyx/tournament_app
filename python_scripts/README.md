# Information on each python script

## parse_create_json.py
### Installation
Ensure that you have [Python 3](https://www.python.org/downloads/) installed.
The `requests` and `marshmallow` packages must be installed.
You can run `pip install requests` and `pip install marshmallow` to install
these packages.

### Operation
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
The script 

## icon_grabber_script.py
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