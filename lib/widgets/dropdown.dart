/// This file contains classes and/or functions relating to the dropdown that
/// allows the user to select a different playoff season. When the user makes
/// a new selection, the playoff graph is regenerated.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tournament_app/exceptions.dart';
import 'package:tournament_app/styles.dart';

/// This widget is for the dropdown that shows options for playoff seasons.
class PlayoffYearDropdown extends StatefulWidget {
  final List<int> playoffYearNums;
  final Function(int) updateCurrentSeason;

  PlayoffYearDropdown(
      {Key? key,
      required this.playoffYearNums,
      required this.updateCurrentSeason})
      : super(key: key);

  @override
  State<PlayoffYearDropdown> createState() => _PlayoffYearDropdownState();
}

/// This is the private State class for the dropdown.
class _PlayoffYearDropdownState extends State<PlayoffYearDropdown> {
  // Default season value is 2018-2019. Options go from 2013-2014 to 2018-2019.
  late String dropdownValue;
  late final List<String> _playoffYearStrs;

  @override
  void initState() {
    super.initState();
    if (widget.playoffYearNums.isEmpty) {
      throw InvalidInputException(
          "Cannot build playoff dropdown with zero options");
    }
    // Create list of options (e.g. "2012-2013"), let default be latest season
    _playoffYearStrs = widget.playoffYearNums
        .map((e) =>
            e.toString().substring(0, 4) + '-' + e.toString().substring(4))
        .toList();
    dropdownValue = _playoffYearStrs.last;
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
        color: Colors.white,
      ),
      dropdownColor: primaryColor,
      onChanged: onDropdownSelect,
      items: _playoffYearStrs.map((playoffsYear) {
        return DropdownMenuItem<String>(
          value: playoffsYear,
          child: Text(playoffsYear),
        );
      }).toList(),
    );
  }

  /// If newValue doesn't equal old value, changes dropdown value and also
  /// tells tournament bracket to regenerate the playoff graph
  void onDropdownSelect(String? newValue) {
    if (newValue == dropdownValue) {
      return;
    }
    int season = int.parse(newValue!.substring(0, 4) + newValue.substring(5));
    setState(() {
      dropdownValue = newValue;
      widget.updateCurrentSeason(season);
    });
  }
}
