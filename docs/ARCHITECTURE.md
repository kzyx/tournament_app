# What?
### What does my underlying Playoff data structure look like?
The Playoff JSON structure is shown below:
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

### What naming convention am I following?
- I followed the [Dart style guide](https://dart.dev/guides/language/effective-dart/style), 
which says:
    - DO name types using UpperCamelCase.
    - DO name libraries, packages, directories, and source files using 
      lowercase_with_underscores.
    - DO name import prefixes using lowercase_with_underscores.
    - DO name other identifiers using lowerCamelCase.
# Why?

### Why did I choose Flutter for this app?
- I had never developed an app in Flutter before and wanted to give it a try.
I had heard great things about how reasonable the learning curve was, and
wanted to find out for myself.

### Why did I choose the NHL Stats API?
- Basically, the main two APIs I was able to find were the NHL Stats API
and the NHL Records API, both documented
[here](https://gitlab.com/dword4/nhlapi/-/tree/master/). The NHL Stats API
had 20 times as much documentation and many more endpoints that were
available. Despite the fact that the NHL Stats API was much better
documented, I still ran into issues where I was unable to get it to give
me the information I had wanted. 

### Why did I choose GraphView for showing my playoff data?
- A tree like structure is an incredibly natural choice for the data that
I'm trying to display (playoff bracket).
- I [typed in graph in pub.dev](https://pub.dev/packages?q=graph) and looked
at the libraries that came up. GraphView was one of the first choices, and when
I dug further, it was apparent that GraphView was by far the most popular and
most supported package for my desired purpose (displaying data in
a graph, or to be specific, a tree) format. I found other minor packages, but
they had nowhere near the support of GraphView 
(159 likes, 110 pub points, 89% popularity at the time of writing this).

### Why did I choose Chewie for my video player?
- [Looking at pub.dev](https://pub.dev/packages?q=video+player) I had a few
possible options. This includes `video_player`, `chewie`, `better_player`,
and `vlc_player`, among others.
- `video_player` was incredibly minimalistic. It had
a flat progress indicator at the bottom instead of one with the draggable
circle. It's an officially supported package and allows low level access
to video playback, but lacks a nice, clean looking UI.
- `chewie` is the second most popular video player on pub.dev
- `better_player` is built on `chewie` and had a bunch of features I knew
I wasn't going to use including really good subtitle support and various
codecs and use cases that were much more advanced than what I was looking for
- `vlc_player` had a default theme I really didn't like and although it was
probably possible to customize I wasn't looking for that much effort

### Biggest advantages of my current design?
- Low latency. The current design does not query any API in order to obtain
playoff data. The time to switch playoff seasons is about as close to as zero
as it can get. Additionally, using the NHL Stats API gives us access to
a wealth of knowledge, including detailed game statistics and game highlights.
- Accessibility. You get access to a ton of information about historical NHL
games at your fingertips.
- Simplicity. The nested JSON structure is a fairly natural representation
of the playoffs.

### Biggest drawbacks of my current design?
- When I began working on this project, I relied on the NHL Stats API very
heavily, as I was making constant GET requests to that API in order to get
playoff data. In an attempt to reduce latency (which was into the seconds),
I first stored the JSON object locally by making a bunch of API calls and
then added branches to the playoff tree corresponding to games, game
stats, etc. I kept adding on to this tree, and ended up with this JSON
object that is basically a one-stop-shop for all the data I need to run
my app. A JSON format isn't fantastic for storing large amounts of data,
and I think some sort of proper database might have been more ideal in hindsight.
- Coupling: there is a coupling concern at this point since the database
is generated using the `parse_create_json.py` script in `python_scripts`.
If I want to add more information to the JSON, I need to add new key-value
pairs, update the `db_schema.py` and `db_schema_serialize.py` files to reflect
this change, but I also need to update the `.dart` files in `model`
that correspond to the modified object.
- Currently very API dependent. As the API has gaps, such as missing highlight
videos for older seasons, missing statistics for older seasons, this is a
limiting factor in this design.
- Currently, adding new fields to the JSON means regenerating the JSON.
Fortunately, this only takes 10 minutes for a dozen seasons.

### Next steps for this app?
- I don't see the next steps of this app being adding regular season
games or something like that. I see the next steps being adding additional
information and features to the playoff seasons.
Some improvements I would like to implement include:
    - Adding more animations. It would be nice to see the team that won a
      round somehow become animated and move to the next round
    - Adding more information. Since we are limited by the NHL Stats API and
      what it has to offer, we could work on finding other sources or crawling
      to obtain certain data. Something like video highlights for older games,
      or game statistics on older games that lack that knowledge.
    - Improving the graph generation algorithm. Right now, it regenerates the
      graph when we switch playoff seasons. A slightly more efficient way to do
      this would be to simply modify the existing graph nodes one by one, as
      then we don't waste time generating the graph vertices and connecting
      the nodes. The graph generation is pretty fast already so this isn't a
      priority.
    - Integrating older years: due to API inconsistencies, certain playoff
      seasons (e.g. 2006-2007, .., 2008-2009) are not supported. 