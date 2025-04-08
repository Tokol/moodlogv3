import 'package:flutter/material.dart';

import '../utils/const_files.dart';

class MoodIntensitySlider extends StatefulWidget {
  final Function(int) onIntensitySelected;
  final String mood;
  final Color moodColor; // Selected Mood

  const MoodIntensitySlider({Key? key, required this.onIntensitySelected, required this.mood,  required this.moodColor,}) : super(key: key);

  @override
  _MoodIntensitySliderState createState() => _MoodIntensitySliderState();
}

class _MoodIntensitySliderState extends State<MoodIntensitySlider> {
  double _selectedLevel = 1; // Default at level 1

  // Mapping mood levels to descriptions & emojis


  @override
  Widget build(BuildContext context) {
    // Get mood levels or default to empty list
    List<Map<String, String>> levels = moodLevels[widget.mood] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Handle case where mood levels might not exist
        if (levels.isNotEmpty)
          Text(
            "${levels[_selectedLevel.toInt() - 1]["emoji"]} ${levels[_selectedLevel.toInt() - 1]["title"]}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        else
          const Text(
            "Select a mood to see intensity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),

        const SizedBox(height: 10),

        // ✅ Horizontal Slider
        Slider(
          value: _selectedLevel,
          min: 1,
          max: 5,
          divisions: 4,
          label: _selectedLevel.round().toString(),
          activeColor: widget.moodColor,
          inactiveColor: Colors.grey.shade300,
          onChanged: levels.isNotEmpty // Only allow sliding if levels exist
              ? (double value) {
            setState(() {
              _selectedLevel = value;
              widget.onIntensitySelected(_selectedLevel.toInt());
            });
          }
              : null, // Disable if no levels available
        ),

        // ✅ Level Numbers 1-5 Below the Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            return Text(
              (index + 1).toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedLevel.toInt() == (index + 1) ? Colors.black : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant MoodIntensitySlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ Reset intensity level if the mood changes
    if (oldWidget.mood != widget.mood) {
      setState(() {
        _selectedLevel = 1; // Reset slider to level 1
      });
    }
  }

}
