
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


import '../../database/database_helper.dart';
import '../../models/mood_log_models.dart';
import '../../utils/const_files.dart';
import '../../widgets/mood_intensity_gauge.dart';
import '../../widgets/mood_intensity_slider.dart';


class MoodSelectionScreen extends StatefulWidget {
  final String selectedTime; // Accepts selected time

  const MoodSelectionScreen({Key? key, required this.selectedTime}) : super(key: key);

  @override
  _MoodSelectionScreenState createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {


  String? selectedLocation; // Stores the selected location
  TextEditingController customLocationController = TextEditingController(); // Controller for "Other" input


  String? selectedMood; // No default selection
  Color? selectedMoodColor; // No default selection
  int selectedIntensityLevel = 1; // Default intensity
  Set<String> selectedFactors = {};
  TextEditingController notesController = TextEditingController();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Selection Title
            const Text("How are you feeling?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Mood Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: moods.map((mood) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = mood["label"];
                      selectedMoodColor = mood["color"];
                      selectedIntensityLevel = 1;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(mood["emoji"], size: 40, color: mood["color"]),
                      Text(
                        mood["label"],
                        style: TextStyle(
                          color: mood["label"] == selectedMood ? mood["color"] : Colors.black,
                          fontWeight: mood["label"] == selectedMood ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // If NO mood is selected, HIDE everything below
            if (selectedMood != null) ...[
              // Main Emoji Display
              Center(
                child: Icon(
                  moods.firstWhere((mood) => mood["label"] == selectedMood)["emoji"],
                  size: 100,
                  color: selectedMoodColor,
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Mood Intensity Title
              Text(
                getMoodIntensityTitle(selectedMood),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Mood Intensity Selector
              MoodIntensitySlider(
                mood: selectedMood!,
                moodColor: selectedMoodColor ?? Colors.blueAccent,
                onIntensitySelected: (int value) {
                  setState(() {
                    selectedIntensityLevel = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Mood Affecting Factors Section
              const Text("What affected your mood?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categorizedMoodAffectingFactors.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key, // Category Title
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: entry.value.map((factor) {
                          final bool isSelected = selectedFactors.contains(factor);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected ? selectedFactors.remove(factor) : selectedFactors.add(factor);
                              });
                            },
                            child: Chip(
                              label: Text(
                                factor,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: isSelected ? Colors.blue.shade900 : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.black),
                              ),
                              deleteIcon: isSelected
                                  ? Icon(Icons.close, size: 16, color: Colors.white)
                                  : null,
                              onDeleted: isSelected
                                  ? () {
                                setState(() {
                                  selectedFactors.remove(factor);
                                });
                              }
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Location Selection
              const Text("Where are you right now?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  ...["Home", "Office", "School/College", "Friend Gathering", "Family Gathering"].map((location) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 24,
                      child: RadioListTile<String>(
                        title: Text(location),
                        value: location,
                        groupValue: selectedLocation,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLocation = value;
                            if (value != "Other") {
                              customLocationController.clear();
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),

              // "Other" Option Below
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: RadioListTile<String>(
                  title: const Text("Other"),
                  value: "Other",
                  groupValue: selectedLocation,
                  onChanged: (String? value) {
                    setState(() {
                      selectedLocation = value;
                      customLocationController.clear();
                    });
                  },
                ),
              ),

              if (selectedLocation == "Other")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: customLocationController,
                    decoration: InputDecoration(
                      hintText: "Your current scene?? (e.g., Date, Vacation, Party...)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                      });
                    },
                  ),
                ),

              const SizedBox(height: 30),

              // Notes Section
              const Text("Notes (Optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: "What’s on your mind? Express your feelings here...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              // Submit Button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedMood == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a mood before submitting.")),
                      );
                      return;
                    }
                    if (selectedFactors.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select at least one factor affecting your mood.")),
                      );
                      return;
                    }
                    if (selectedLocation == null || (selectedLocation == "Other" && customLocationController.text.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please specify your location.")),
                      );
                      return;
                    }

                    // Create MoodLog Object
                    final moodLog = MoodLog(
                      mood: selectedMood!,
                      intensityLevel: selectedIntensityLevel,
                      moodFactors: selectedFactors.toList(),
                      location: selectedLocation == "Other" ? customLocationController.text : selectedLocation!,
                      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : "",
                      selectedTime: widget.selectedTime,
                      selectedDate: DateTime.now(),
                    );

                    // ✅ Insert MoodLog into Database
                    await DatabaseHelper.instance.insertMoodLog(moodLog);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mood logged successfully!")),
                    );

                    Navigator.pop(context, true);


                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Log Mood",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }


  String getMoodIntensityTitle(String? mood) {
    switch (mood) {
      case "Angry":
        return "How angry are you? 😡";
      case "Sad":
        return "How sad are you? 😢";
      case "Anxious":
        return "How anxious are you? 😰";
      case "Calm":
        return "How calm do you feel? 😌";
      case "Happy":
        return "How happy are you? 😃";
      default:
        return ""; // Empty if no mood is selected
    }
  }
}

// Gauge Meter (1-5) for Selecting Mood Intensity


