import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tournament_app/widgets/tournament_bracket.dart';

/// This widget is for the dropdown that shows options for playoff seasons
class PlayoffsYearDropdown extends StatefulWidget {
  late List<int> playoffsYearNums;

  PlayoffsYearDropdown({Key? key, required List<int> playoffsYearNums})
      : super(key: key) {
    this.playoffsYearNums = playoffsYearNums;
  }

  @override
  State<PlayoffsYearDropdown> createState() => _PlayoffsYearDropdownState();
}

/// This is the private State class for the dropdown
class _PlayoffsYearDropdownState extends State<PlayoffsYearDropdown> {
  // Default season value is 2018-2019. Options go from 2013-2014 to 2018-2019.
  late String dropdownValue;
  late final List<int> playoffsYearNums;
  late final List<String> playoffsYearStrs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.playoffsYearNums.isEmpty) {
      throw Exception("Cannot build playoff dropdown with zero options");
    }
    playoffsYearNums = widget.playoffsYearNums;
    List<String> temp = [];
    playoffsYearNums.forEach((e) {
      temp.add(e.toString().substring(0, 4) + '-' + e.toString().substring(4));
    });
    playoffsYearStrs = temp;
    dropdownValue = playoffsYearStrs.last;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      dropdownColor: Colors.blue,
      onChanged: (String? newValue) {
        // Update selected playoff year and make the playoff bracket update
        if (newValue == dropdownValue) {
          return;
        }
        int season =
            int.parse(newValue!.substring(0, 4) + newValue.substring(5));
        setState(() {
          dropdownValue = newValue;
          treeViewPageKey.currentState!.updateCurrentSeason(season);

          // treeViewPageKey.currentState!.finishedLoading = false;
        });
      },
      items: playoffsYearStrs.map((playoffsYear) {
        return DropdownMenuItem<String>(
          value: playoffsYear,
          child: Text(playoffsYear),
        );
      }).toList(),
    );
  }
}
