import 'package:flutter/material.dart';


import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../database/database_helper.dart';
import '../../../models/mood_log_models.dart';
import '../../../utils/const_files.dart';
import '../../../widgets/charts/custom_mood_bar_graph.dart';
import '../../../widgets/charts/mood_trend.dart';




class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<MoodLog> moodLogs = [];
  String selectedFilter = "Weekly"; // ✅ Default to Weekly
  bool showAllTriggers = false;
  String? expandedMood;// State to control visibility
  bool showAllLocations = false;

  @override
  void initState() {
    super.initState();
    //insertDummyData();
    _loadMoodData();
  }








  /// ✅ **Load Mood Data Based on Selected Filter**
  Future<void> _loadMoodData() async {


    DateTime now = DateTime.now();
    String startDate;

    if (selectedFilter == "Weekly") {
      startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
    } else if (selectedFilter == "Monthly") {
      startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, now.day));
    }

   else if (selectedFilter == "Yearly") {
      startDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year - 1, now.month, now.day));
  }
    else if(selectedFilter=="All time"){
      startDate = "0000-00-00";
    }

    else {
      startDate = "0000-00-00";
    }

    final moods = (selectedFilter == "All Time")
        ? await DatabaseHelper.instance.getAllMoods() // ✅ Fetch all-time data
        : await DatabaseHelper.instance.getMoodsInRange(startDate, DateFormat('yyyy-MM-dd').format(now));
    setState(() {
      moodLogs = moods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: moodLogs.isEmpty
          ? const Center(child: Text("No mood data available"))
          : SafeArea(

            child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ **Filter Selector**
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton("Weekly"),
                    _buildFilterButton("Monthly"),
                    _buildFilterButton("Yearly"),
                    _buildFilterButton("All Time"),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Text("Mood Trends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              MoodTrendsChart(moodLogs: moodLogs, selectedFilter: selectedFilter),


              const SizedBox(height: 20),
              const Text("Mood Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildMoodDistributionChart(),

              const SizedBox(height: 20),

               Text(showAllTriggers ? "All Trigger Factors" : "Top 5 Trigger Factors", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildMoodTriggersChart(),

            //  const SizedBox(height: 8),
              const Text("Mood at Different Locations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildLocationMoodChart(),

              const SizedBox(height: 20),
              const Text("Time-Based Mood Patterns", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildTimeBasedMoodChart(),
            ],
                    ),
                  ),
          ),
    );
  }

  /// **Filter Button**
  Widget _buildFilterButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedFilter = label;
            _loadMoodData();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedFilter == label ? Colors.black : Colors.yellow.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// **Mood Trends Chart (Line Chart)**
  /// **Mood Trends Chart (Line Chart) with Intensity Labels & Emoji Tooltips**







  /// **Show Tooltip on Emoji Tap**



  /// ✅ **Fixing the Overflow Issue**


  /// ✅ **Helper Function to Get Emoji for a Mood**
  String getEmojiForMood(String mood, int intensityLevel) {
    return moodLevels[mood]?[2]["emoji"] ?? "❓"; // Default to medium intensity
  }




  /// **Mood Distribution Chart (Pie Chart)**
  Widget _buildMoodDistributionChart() {
    Map<String, int> moodCounts = {};
    for (var log in moodLogs) {
      moodCounts[log.mood] = (moodCounts[log.mood] ?? 0) + 1;
    }

    int totalMoods = moodCounts.values.fold(0, (sum, count) => sum + count);

    List<PieChartSectionData> sections = moodCounts.entries.map((entry) {
      double percentage = (entry.value / totalMoods) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: "${_getDominantEmojiForMood(entry.key)}\n${entry.key}\n${percentage.toStringAsFixed(1)}%",
        color: _getMoodColor(entry.key),
        radius: 50,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 10),

        /// ✅ **Legend Below the Chart**
        Wrap(
          spacing: 10,
          children: moodCounts.entries.map((entry) {
            double percentage = (entry.value / totalMoods) * 100;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getMoodColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${getEmojiForMood(entry.key, 3)} ${entry.key} (${percentage.toStringAsFixed(1)}%)",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// **Find the Most Frequent Emoji for a Mood**
  String _getDominantEmojiForMood(String mood) {
    // Count intensity levels for the given mood
    Map<int, int> intensityCounts = {};

    for (var log in moodLogs) {
      if (log.mood == mood) {
        intensityCounts[log.intensityLevel] = (intensityCounts[log.intensityLevel] ?? 0) + 1;
      }
    }

    // Get the most frequent intensity level
    int dominantIntensity = intensityCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Return the emoji with the dominant intensity level
    return getEmojiForMood(mood, dominantIntensity);
  }



  /// **Mood Triggers Analysis (Bar Chart)**






  Widget _buildMoodTriggersChart() {
    Map<String, Map<String, int>> moodData = {};

    // Collect mood data without repeating triggers
    for (var log in moodLogs) {
      for (var factor in log.moodFactors) {
        if (!moodData.containsKey(factor)) {
          moodData[factor] = {};
        }
        String moodText = log.mood;
        moodData[factor]![moodText] = (moodData[factor]![moodText] ?? 0) + 1;
      }
    }

    // Sort triggers by total occurrences
    List<MapEntry<String, Map<String, int>>> sortedTriggers = moodData.entries.toList()
      ..sort((a, b) => b.value.values.fold(0, (sum, v) => sum + v)
          .compareTo(a.value.values.fold(0, (sum, v) => sum + v)));

    // Take the top 5 triggers
    List<MapEntry<String, Map<String, int>>> topTriggers = sortedTriggers.take(5).toList();

    // Decide which triggers to show
    List<MapEntry<String, Map<String, int>>> triggersToShow = showAllTriggers ? sortedTriggers : topTriggers;

    // Calculate total moods for percentage calculation
    int totalMoods = moodLogs.length;

    // Create a set of unique moods for the legend
    Set<String> uniqueMoods = {};
    for (var entry in triggersToShow) {
      uniqueMoods.addAll(entry.value.keys);
    }

    return Column(
      children: [
        // Header: Top 5 or All Trigger Factors
        // Bar Graph for Each Trigger
        ...triggersToShow.map((entry) {
          String trigger = entry.key;
          Map<String, int> moodCounts = entry.value;

          // Calculate the total occurrences for this trigger
          int totalOccurrences = moodCounts.values.fold(0, (sum, v) => sum + v);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trigger Name
                Text(
                  trigger,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // Bar Graph
                Stack(
                  children: [
                    // Background Bar
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Filled Bars for Each Mood
                    Row(
                      children: moodCounts.entries.map((moodEntry) {
                        String mood = moodEntry.key;
                        int count = moodEntry.value;
                        double percentage = (count / totalOccurrences) * 100;

                        // Hide text if the segment is too small
                        bool showText = (percentage / 100) * MediaQuery.of(context).size.width * 0.8 > 30;

                        return GestureDetector(
                          onTap: () {
                            // Show a tooltip with the mood and percentage
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${getEmojiForMood(mood, 3)} $mood: ${percentage.toStringAsFixed(1)}%"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            height: 20,
                            width: (percentage / 100) * MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: _getMoodColor(mood),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: showText
                                  ? Text(
                                "${getEmojiForMood(mood, 3)} ${percentage.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )
                                  : const SizedBox(), // Hide text if the segment is too small
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        // Show More / Show Less Button
        TextButton(
          onPressed: () {
            setState(() {
              showAllTriggers = !showAllTriggers; // Toggle visibility
            });
          },
          child: Text(
            showAllTriggers ? "Show Less" : "Show More",
            style: TextStyle(color: Colors.blue),
          ),
        ),

        // Legend
        const SizedBox(height: 20),
        const Text(
          "Legend",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: uniqueMoods.map((mood) => _buildLegendItem(mood)).toList(),
        ),
      ],
    );
  }





  /// **Helper Function: Get Mood Color**

  Widget _buildTimeBasedMoodChart() {
    // Initialize timeMoodCounts with default values
    Map<String, Map<String, int>> timeMoodCounts = {
      "Morning": {for (var mood in moods) mood["label"]: 0},
      "Afternoon": {for (var mood in moods) mood["label"]: 0},
      "Evening": {for (var mood in moods) mood["label"]: 0},
      "Night": {for (var mood in moods) mood["label"]: 0},
    };

    print("Mood Logs Count: ${moodLogs.length}");

    for (var log in moodLogs) {
      try {
        // Normalize the time format (e.g., "7 AM" -> "07:00 AM")
        final parsedTime = DateFormat('h a').parse(log.selectedTime);
        final normalizedTime = DateFormat('HH:mm a').format(parsedTime);

        // Determine the time slot for the log
        String timeSlot;
        final hour = parsedTime.hour;

        if (hour >= 0 && hour < 6) {
          timeSlot = "Night";
        } else if (hour >= 6 && hour < 12) {
          timeSlot = "Morning";
        } else if (hour >= 12 && hour < 18) {
          timeSlot = "Afternoon";
        } else {
          timeSlot = "Evening";
        }

        // Update mood counts for the time slot
        if (timeMoodCounts[timeSlot]!.containsKey(log.mood)) {
          timeMoodCounts[timeSlot]![log.mood] = timeMoodCounts[timeSlot]![log.mood]! + 1;
        } else {
          timeMoodCounts[timeSlot]![log.mood] = 1;
        }
      } catch (e) {
        print("❌ Error parsing time for log: '${log.selectedTime}' -> $e");
      }
    }

    Color getColorWithIntensity(Color baseColor, int intensity) {
      assert(intensity >= 1 && intensity <= 5);
      return baseColor.withOpacity(intensity / 5);
    }

    return Column(
      children: [
        // Heatmap Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: moods.length + 1, // Moods + 1 for time slot labels
            childAspectRatio: 1.5,
          ),
          itemCount: (timeMoodCounts.length + 1) * (moods.length + 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Center(child: Text("")); // Empty top-left corner
            }
            if (index < moods.length + 1) {
              // Mood labels (first row) with emoji
              final mood = moods[index - 1];
              final emoji = moodLevels[mood["label"]]?[0]["emoji"] ?? "❓"; // Get the emoji for the mood
              return Center(
                child: Text(
                  "  $emoji \n${mood["label"]}", // Display mood label with emoji
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }
            if (index % (moods.length + 1) == 0) {
              // Time slot labels (first column) - Simplified labels
              return Center(
                child: Text(
                  timeMoodCounts.keys.toList()[(index ~/ (moods.length + 1)) - 1],
                  style: const TextStyle(  fontWeight: FontWeight.bold, fontSize: 13),
                ),
              );
            }
            // Heatmap cells
            final timeSlot = timeMoodCounts.keys.toList()[(index ~/ (moods.length + 1)) - 1];
            final mood = moods[(index % (moods.length + 1)) - 1]["label"];
            final count = timeMoodCounts[timeSlot]?[mood] ?? 0; // Get the count of the mood

            // Handle no data (count == 0)
            final isNoData = count == 0;
            final cellColor = isNoData
                ? Colors.transparent // No color for no data
                : getColorWithIntensity(moods.firstWhere((m) => m["label"] == mood)["color"], 1); // Use base color

            final cellText = isNoData ? "N/A" : count.toString(); // Display "N/A" for no data

            final tooltipMessage = isNoData
                ? "No data available"
                : "${moodLevels[mood]![0]["title"]} ${moodLevels[mood]![0]["emoji"]}"; // Use the first level's title and emoji

            return Tooltip(
              message: tooltipMessage,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cellColor,
                  border: isNoData ? Border.all(color: Colors.black) : null, // Add border for no data
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    cellText,
                    style: TextStyle(
                      color: isNoData ? Colors.black : Colors.white, // Black text for no data, white for colored cells
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Increase font size for better visibility
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Time Slot Legend
        _buildTimeSlotLegend(),

        const SizedBox(height: 16),

        // Mood Legend
        _buildLegendsTimeBased(moods),
      ],
    );
  }


  Widget _buildTimeSlotLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Time Slots",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildTimeSlotLegendItem("Morning (6 AM - 12 PM)"),
            _buildTimeSlotLegendItem("Afternoon (12 PM - 6 PM)"),
            _buildTimeSlotLegendItem("Evening (6 PM - 12 AM)"),
            _buildTimeSlotLegendItem("Night (12 AM - 6 AM)"),
          ],
        ),
      ],
    );
  }

// Helper to Build Time Slot Legend Items
  Widget _buildTimeSlotLegendItem(String timeSlot) {
    // Define icons and colors for each time slot
    IconData icon;
    Color iconColor;
    switch (timeSlot) {
      case "Morning (6 AM - 12 PM)":
        icon = Icons.wb_sunny; // Sun icon for morning
        iconColor = Colors.orange; // Orange color for morning
        break;
      case "Afternoon (12 PM - 6 PM)":
        icon = Icons.brightness_5; // Bright sun icon for afternoon
        iconColor = Colors.yellow.shade700; // Yellow color for afternoon
        break;
      case "Evening (6 PM - 12 AM)":
        icon = Icons.brightness_4; // Sunset icon for evening
        iconColor = Colors.purple; // Purple color for evening
        break;
      case "Night (12 AM - 6 AM)":
        icon = Icons.nights_stay; // Moon icon for night
        iconColor = Colors.black; // Black color for night
        break;
      default:
        icon = Icons.error; // Fallback icon
        iconColor = Colors.grey; // Fallback color
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor, // Use the assigned color for the icon
        ),
        const SizedBox(width: 4),
        Text(
          timeSlot,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }







// Build the Emoji-based Legend
  Widget _buildLegendsTimeBased(List<Map<String, dynamic>> moods) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns
        childAspectRatio: 2, // Adjust the aspect ratio as needed
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final emoji = moodLevels[mood["label"]]?[0]["emoji"] ?? "❓"; // Get the emoji for the mood
        final color = mood["color"]; // Base color for the mood

        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mood Label with Emoji
                Text(
                  "$emoji ${mood["label"]}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Intensity Levels (1 to 5)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (intensityIndex) {
                    final intensity = intensityIndex + 1;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color.withOpacity(intensity / 5), // Adjust opacity based on intensity
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          intensity.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: intensity > 2 ? Colors.white : Colors.black, // Adjust text color for visibility
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String mood) {
    // Filter logs for the selected mood
    List<MoodLog> filteredLogs = moodLogs.where((log) => log.mood == mood).toList();

    // Calculate trigger contributions
    Map<String, double> triggerContributions = _calculateTriggerContributions(mood);

    return Column(
      children: [
        ListTile(
          onTap: () {
            setState(() {
              expandedMood = expandedMood == mood ? null : mood; // Toggle expanded mood
            });
          },
          leading: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getMoodColor(mood),
              shape: BoxShape.circle,
            ),
          ),
          title: Text(
            "${getEmojiForMood(mood, 3)} $mood",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            expandedMood == mood ? Icons.expand_less : Icons.expand_more,
          ),
        ),
        if (expandedMood == mood) _buildExpandableSection(mood, triggerContributions, filteredLogs),
      ],
    );
  }


  Widget _buildExpandableSection(String mood, Map<String, double> triggerContributions, List<MoodLog> filteredLogs) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Emoji and Mood Name
            Center(
              child: Column(
                children: [
                  Text(
                    getEmojiForMood(mood, 3),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mood,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trigger Contributions
            const Text(
              "Trigger Contributions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...triggerContributions.entries.map((entry) {
              String trigger = entry.key;
              double percentage = entry.value;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            getTriggerIcon(trigger), // Use the new icon mapping
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trigger,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(mood)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold), // Updated color
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),


          ],
        ),
      ),
    );
  }


  Map<String, double> _calculateTriggerContributions(String mood) {
    // Filter logs for the selected mood
    List<MoodLog> filteredLogs = moodLogs.where((log) => log.mood == mood).toList();

    // Count occurrences of each trigger
    Map<String, int> triggerCounts = {};
    for (var log in filteredLogs) {
      for (var factor in log.moodFactors) {
        triggerCounts[factor] = (triggerCounts[factor] ?? 0) + 1;
      }
    }

    // Calculate percentage contributions
    int totalOccurrences = triggerCounts.values.fold(0, (sum, count) => sum + count);
    Map<String, double> triggerContributions = {};
    triggerCounts.forEach((trigger, count) {
      double percentage = (count / totalOccurrences) * 100;
      triggerContributions[trigger] = percentage;
    });

    return triggerContributions;
  }




  /// **Location-Based Mood Analysis (Pie Chart)**
  Widget _buildLocationMoodChart() {
    Map<String, int> locationCounts = {};
    Map<String, Map<String, int>> locationMoodCounts = {};

    // Collect data
    for (var log in moodLogs) {
      // Count total logs per location
      locationCounts[log.location] = (locationCounts[log.location] ?? 0) + 1;

      // Count moods per location
      if (!locationMoodCounts.containsKey(log.location)) {
        locationMoodCounts[log.location] = {};
      }
      locationMoodCounts[log.location]![log.mood] = (locationMoodCounts[log.location]![log.mood] ?? 0) + 1;
    }

    // Sort locations by total logs (highest first)
    List<MapEntry<String, int>> sortedLocations = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Find the maximum number of logs for scaling
    int maxLogs = sortedLocations.isNotEmpty ? sortedLocations.first.value : 1;

    return Column(
      children: [
        // Custom Bar Graph with Horizontal Scroll
        SizedBox(
          height: 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sortedLocations.map((entry) {
                String location = entry.key;
                int totalLogs = entry.value;
                Map<String, int> moodCounts = locationMoodCounts[location]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bar
                      Container(
                        width: 50, // Fixed width for each bar
                        height: (totalLogs / maxLogs) * 200, // Scale height based on max logs
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade800],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: moodCounts.entries.map((moodEntry) {
                            String mood = moodEntry.key;
                            int count = moodEntry.value;
                            double percentage = (count / totalLogs) * 100;

                            return Container(
                              height: (count / totalLogs) * ((totalLogs / maxLogs) * 200), // Scale segment height
                              decoration: BoxDecoration(
                                color: _getMoodColor(mood), // Mood color
                                borderRadius: BorderRadius.vertical(
                                  bottom: moodCounts.entries.toList().indexOf(moodEntry) == 0
                                      ? Radius.circular(8) // Rounded bottom for the first segment
                                      : Radius.zero,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${getEmojiForMood(mood, 3)} ${percentage.toStringAsFixed(1)}%",
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location Name with Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            getLocationIcon(location), // Location icon
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Legend
        const SizedBox(height: 20),
        const Text(
          "Legend",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: locationMoodCounts.values
              .expand((moodCounts) => moodCounts.keys)
              .toSet()
              .map((mood) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "${getEmojiForMood(mood, 3)} $mood",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }


// Helper function to get an icon for each location


  /// **Time-Based Mood Patterns (Grouped Bar Chart)**




  Color getColorWithIntensity(Color baseColor, int intensity) {
    assert(intensity >= 1 && intensity <= 5); // Ensures valid range
    return baseColor.withOpacity(intensity / 5); // Adjusts opacity
  }




  /// **Helper Function: Get Mood Color**
  Color _getMoodColor(String mood) {
    return {
      "Happy": Colors.orange,
      "Sad": Colors.amber.shade700,
      "Angry": Colors.red,
      "Anxious": Colors.blue,
      "Calm": Colors.green
    }[mood] ?? Colors.grey;
  }
}


