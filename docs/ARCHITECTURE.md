### Why did I choose Flutter for this app?
- I had never developed an app in Flutter before and wanted to give it a try.
I had heard great things about how reasonable the learning curve was, and
wanted to find out for myself.

### Why did I choose GraphView for showing my playoff data?
- A tree like structure is an incredibly natural choice for the data that
I'm trying to display (playoff bracket)
- I [typed in graph in pub.dev](https://pub.dev/packages?q=graph) and looked
at the libraries that came up. GraphView was one of the first choices, and when
I dug further, it was apparent that GraphView was by far the most popular and
most supported package for my purposes, which were about displaying data in
a graph (tree, to be specific) format. I found other minor packages, but they
had nowhere near the support of GraphView 
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

### Biggest drawbacks of my current design?
- When I began working on this project, I relied on the NHL Stats API very
heavily, as I was making constant GET requests to that API in order to get
playoff data. In an attempt to reduce latency (which was into the seconds),
I first stored the JSON object locally by making a bunch of API calls and
then added branches to the playoff tree corresponding to games, game
stats, etc. I kept adding on to this tree, and ended up with this JSON
object that is basically a one-stop-shop for all the data I need to run
my app. A JSON format isn't fantastic, and I think some sort of proper
database might have been more ideal in hindsight.
- Coupling: there is a coupling concern at this point since