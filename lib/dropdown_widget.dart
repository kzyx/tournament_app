import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tournament_app/treeviewpage_widget.dart';

/// This widget is for the dropdown that shows options for playoff seasons
class PlayoffsYearDropdown extends StatefulWidget {
  const PlayoffsYearDropdown({Key? key}) : super(key: key);

  @override
  State<PlayoffsYearDropdown> createState() => _PlayoffsYearDropdownState();
}

/// This is the private State class for the dropdown
class _PlayoffsYearDropdownState extends State<PlayoffsYearDropdown> {
  // Default season value is 2018-2019. Options go from 2013-2014 to 2018-2019.
  String dropdownValue = '2018-2019';
  final List<String> playoffsYear =
      List<String>.generate(6, (i) => '20${(i + 13)}' + '-20${(i + 14)}');

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        if (newValue == dropdownValue) {
          return;
        }
        int season =
            int.parse(newValue!.substring(0, 4) + newValue.substring(5));
        setState(() {
          dropdownValue = newValue;
          treeViewPageKey.currentState!.finishedLoading = false;
          debugPrint(season.toString());
        });
        treeViewPageKey.currentState!.generateGraphFromPlayoffs(season);
      },
      items: playoffsYear.map((playoffsYear) {
        return DropdownMenuItem<String>(
          value: playoffsYear,
          child: Text(playoffsYear),
        );
      }).toList(),
    );
  }
}
