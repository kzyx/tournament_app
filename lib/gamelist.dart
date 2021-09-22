import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:tournament_app/dropdown.dart';
import 'package:tournament_app/models/all.dart';
import 'package:tournament_app/treeviewpage.dart';
import 'package:tournament_app/utils.dart' as Utils;

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}

/// This widget is for the dropdown that shows options for playoff seasons
class GameListPopup extends StatefulWidget {
  final Series series;

  const GameListPopup({Key? key, required this.series}) : super(key: key);

  @override
  State<GameListPopup> createState() => _GameListPopupState(this.series);
}

/// This is the private State class for the dropdown
class _GameListPopupState extends State<GameListPopup> {
// stores ExpansionPanel state information

  Series series;
  late List<Item> _data;

  _GameListPopupState(this.series) {
    int numberOfGames = this.series.currentGame.seriesSummary.gameNumber;
    _data = List<Item>.generate(numberOfGames,
        (i) => Item(expandedValue: "test123", headerValue: 'Game ${(i + 1)}'));

    // _data = List<Item>.generate((i))
    // for (int i = 0; i < numberOfGames; i++) {
    //   _data
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          backgroundColor: Colors.orange,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue, style: whiteBoldText),
            );
          },
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    title: Text(item.expandedValue),
                    subtitle: const Text(
                        'ayon'),
                    trailing: const Icon(Icons.video_collection),
                    onTap: () {

                    }),
                ListTile(
                    title: Text("Watch highlights", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    // subtitle: const Text(
                    //     'To delete this panel, tap the trash can icon'),
                    trailing: const Icon(Icons.video_collection),
                    onTap: () {
                      setState(() {
                        _data.removeWhere(
                                (Item currentItem) => item == currentItem);
                      });
                    })
              ]),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
