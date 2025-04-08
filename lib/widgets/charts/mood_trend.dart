
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/mood_log_models.dart';
import '../../utils/const_files.dart';

class MoodTrendsChart extends StatefulWidget {
  final List<MoodLog> moodLogs;
  final String selectedFilter; // Added to check if "Monthly" is selected

  const MoodTrendsChart({Key? key, required this.moodLogs, required this.selectedFilter}) : super(key: key);

  @override
  _MoodTrendsChartState createState() => _MoodTrendsChartState();
}

class _MoodTrendsChartState extends State<MoodTrendsChart> {
  MoodLog? selectedMoodLog;
  Offset? tooltipPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.moodLogs.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    DateTime firstDate = widget.moodLogs.first.selectedDate;

    // ✅ Check if it's "Monthly" view, then group by week


    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  //tooltipBgColor: Colors.black87,
                  tooltipRoundedRadius: 8,
                  fitInsideVertically: true,
                  fitInsideHorizontally: true,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      MoodLog moodLog = widget.moodLogs[touchedSpot.spotIndex];
                      return LineTooltipItem(
                        "${getEmojiForMood(moodLog.mood, moodLog.intensityLevel)} ${moodLog.mood} (${moodLog.intensityLevel})",
                        const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true, // ✅ Enables FLChart's built-in touch handling
              ),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 1: return const Text("Slightly", style: TextStyle(fontSize: 10));
                        case 2: return const Text("Mildly", style: TextStyle(fontSize: 10));
                        case 3: return const Text("Moderate", style: TextStyle(fontSize: 10));
                        case 4: return const Text("Highly", style: TextStyle(fontSize: 10));
                        case 5: return const Text("Extreme", style: TextStyle(fontSize: 10));
                        default: return const SizedBox();
                      }
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (widget.selectedFilter == "Monthly") {
                        // ✅ Show Weeks for Monthly View
                        int weekNum = value.toInt() + 1;
                        String weekLabel = "$weekNum Week";
                        String emoji = _getDominantMoodPerWeek()[weekNum]?["emoji"] ?? "❓";
                        int count = _getDominantMoodPerWeek()[weekNum]?["count"] ?? 0;
                        String moodTitle = _getDominantMoodPerWeek()[weekNum]?["title"] ?? "Unknown";

                        return GestureDetector(
                          onTap: () => _showMoodDetails(context, emoji, moodTitle, count),
                          child: Column(
                            children: [
                              Text(weekLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      }
                      else if (widget.selectedFilter == "Yearly") {
                        // ✅ Show Months for Yearly View
                        DateTime now = DateTime.now();
                        DateTime startMonth = DateTime(now.year - 1, now.month, 1);
                        DateTime monthToShow = DateTime(startMonth.year, startMonth.month + value.toInt(), 1); // 🔹 Rolling 12 months

                        String monthLabel = DateFormat('MMM').format(monthToShow); // Jan, Feb, Mar...
                        String emoji = _getDominantMoodPerMonth()[monthToShow.month]?["emoji"] ?? "❓";
                        int count = _getDominantMoodPerMonth()[monthToShow.month]?["count"] ?? 0;
                        String moodTitle = _getDominantMoodPerMonth()[monthToShow.month]?["title"] ?? "Unknown";

                        return GestureDetector(
                          onTap: () => _showMoodDetails(context, emoji, moodTitle, count),
                          child: Column(
                            children: [
                              Text(monthLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      }

                      else if (widget.selectedFilter == "All Time") {
                        List<int> yearRange = _getYearRange();
                        int yearIndex = value.toInt();

                        if (yearIndex < 0 || yearIndex >= yearRange.length) return const SizedBox(); // Prevent invalid values

                        int yearToShow = yearRange[yearIndex]; // Get the actual year

                        String emoji = _getDominantMoodPerYear()[yearToShow]?["emoji"] ?? "❓";
                        int count = _getDominantMoodPerYear()[yearToShow]?["count"] ?? 0;
                        String moodTitle = _getDominantMoodPerYear()[yearToShow]?["title"] ?? "Unknown";

                        return GestureDetector(
                          onTap: () => _showMoodDetails(context, emoji, moodTitle, count),
                          child: Column(
                            children: [
                              Text(yearToShow.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      }



                      else {
                        // ✅ Show Days for Weekly View
                        DateTime date = firstDate.add(Duration(days: value.toInt()));
                        String dayLabel = DateFormat('E').format(date);
                        String emoji = _getDominantMoodPerDay()[dayLabel]?["emoji"] ?? "❓";
                        int count = _getDominantMoodPerDay()[dayLabel]?["count"] ?? 0;
                        String moodTitle = _getDominantMoodPerDay()[dayLabel]?["title"] ?? "Unknown";

                        return GestureDetector(
                          onTap: () => _showMoodDetails(context, emoji, moodTitle, count),
                          child: Column(
                            children: [
                              Text(dayLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),


              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: widget.moodLogs.map((log) {
                    double xValue;

                    if (widget.selectedFilter == "Monthly") {
                      xValue = _getWeekNumber(log.selectedDate) - 1; // Weeks: 0-3
                    }
                    else if (widget.selectedFilter == "Yearly") {
                      DateTime now = DateTime.now();
                      DateTime startMonth = DateTime(now.year - 1, now.month, 1); // 🔹 Start from 12 months ago

                      int monthsSinceStart = (log.selectedDate.year - startMonth.year) * 12 + (log.selectedDate.month - startMonth.month);
                      xValue = monthsSinceStart.toDouble(); // 🔹 Months: 0-11
                    }
                    else if (widget.selectedFilter == "All Time") {
                      List<int> yearRange = _getYearRange();
                      int yearIndex = yearRange.indexOf(log.selectedDate.year); // Map year to index
                      xValue = yearIndex.toDouble(); // ✅ Convert year index to X-Axis value
                    }



                    else {
                      xValue = log.selectedDate.difference(firstDate).inDays.toDouble(); // Daily Trends
                    }

                    return FlSpot(xValue, log.intensityLevel.toDouble());
                  }).toList(),

                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, index) {
                      return FlDotCirclePainter(
                        radius: 4, // 🔹 Reduced dot size to avoid overlap
                        color: Colors.blue,
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],


            ),
          ),
        ),

        // ✅ Show Tooltip Above the Selected Data Point
        if (selectedMoodLog != null && tooltipPosition != null)
          Positioned(
            left: tooltipPosition!.dx - 50,
            top: tooltipPosition!.dy - 60,
            child: _buildTooltip(selectedMoodLog!),
          ),
      ],
    );
  }

  Map<String, Map<String, dynamic>> _getDominantMoodPerDay() {
    Map<String, Map<String, int>> moodFrequency = {};

    for (var log in widget.moodLogs) {
      String day = DateFormat('E').format(log.selectedDate);
      String emoji = getEmojiForMood(log.mood, log.intensityLevel);
      String moodTitle = log.mood;

      if (!moodFrequency.containsKey(day)) {
        moodFrequency[day] = {};
      }
      moodFrequency[day]![emoji] = (moodFrequency[day]![emoji] ?? 0) + 1;
    }

    Map<String, Map<String, dynamic>> dominantMoods = {};
    moodFrequency.forEach((day, emojiCounts) {
      String dominantEmoji = emojiCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      int count = emojiCounts[dominantEmoji] ?? 0;
      dominantMoods[day] = {"emoji": dominantEmoji, "count": count, "title": moodLevels.entries.firstWhere((e) => e.value[2]["emoji"] == dominantEmoji, orElse: () => MapEntry("Unknown", <Map<String, String>>[])).key};
    });

    return dominantMoods;
  }

  Map<int, Map<String, dynamic>> _getDominantMoodPerWeek() {
    Map<int, Map<String, int>> moodFrequency = {};

    for (var log in widget.moodLogs) {
      int weekNum = _getWeekNumber(log.selectedDate);
      String emoji = getEmojiForMood(log.mood, log.intensityLevel);
      String moodTitle = log.mood;

      if (!moodFrequency.containsKey(weekNum)) {
        moodFrequency[weekNum] = {};
      }
      moodFrequency[weekNum]![emoji] = (moodFrequency[weekNum]![emoji] ?? 0) + 1;
    }

    Map<int, Map<String, dynamic>> dominantMoods = {};
    moodFrequency.forEach((week, emojiCounts) {
      String dominantEmoji = emojiCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      int count = emojiCounts[dominantEmoji] ?? 0;
      dominantMoods[week] = {
        "emoji": dominantEmoji,
        "count": count,
        "title": moodLevels.entries
            .firstWhere(
              (e) => e.value[2]["emoji"] == dominantEmoji,
          orElse: () => MapEntry("Unknown", <Map<String, String>>[]),
        )
            .key
      };    });

    return dominantMoods;
  }


  /// **🔹 Handle Tap & Show Tooltip Above the Selected Data Point**
  void _showMoodDetails(BuildContext context, String emoji, String moodTitle, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Mood Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$emoji  $moodTitle",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text("Occurred: $count times"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  /// **🔹 Get the Dominant Mood for Each Month**
  Map<int, Map<String, dynamic>> _getDominantMoodPerMonth() {
    Map<int, Map<String, int>> moodFrequency = {};

    for (var log in widget.moodLogs) {
      int monthNum = log.selectedDate.month; // ✅ Extract month (1-12)
      String emoji = getEmojiForMood(log.mood, log.intensityLevel);

      if (!moodFrequency.containsKey(monthNum)) {
        moodFrequency[monthNum] = {};
      }
      moodFrequency[monthNum]![emoji] = (moodFrequency[monthNum]![emoji] ?? 0) + 1;
    }

    // ✅ Find the most frequent mood for each month
    Map<int, Map<String, dynamic>> dominantMoods = {};
    moodFrequency.forEach((month, emojiCounts) {
      String dominantEmoji = emojiCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      int count = emojiCounts[dominantEmoji] ?? 0;

      dominantMoods[month] = {
        "emoji": dominantEmoji,
        "count": count,
        "title": moodLevels.entries.firstWhere(
              (e) => e.value[2]["emoji"] == dominantEmoji,
          orElse: () => MapEntry("Unknown", <Map<String, String>>[]),
        ).key
      };
    });

    return dominantMoods;
  }

  /// **Get First and Last Year from Data**
  List<int> _getYearRange() {
    if (widget.moodLogs.isEmpty) return [];

    int firstYear = widget.moodLogs.map((log) => log.selectedDate.year).reduce((a, b) => a < b ? a : b);
    int lastYear = widget.moodLogs.map((log) => log.selectedDate.year).reduce((a, b) => a > b ? a : b);

    return List.generate(lastYear - firstYear + 1, (index) => firstYear + index);
  }

  /// **Get the Dominant Mood for Each Year**
  Map<int, Map<String, dynamic>> _getDominantMoodPerYear() {
    Map<int, Map<String, int>> moodFrequency = {};

    for (var log in widget.moodLogs) {
      int year = log.selectedDate.year;
      String emoji = getEmojiForMood(log.mood, log.intensityLevel);

      if (!moodFrequency.containsKey(year)) {
        moodFrequency[year] = {};
      }
      moodFrequency[year]![emoji] = (moodFrequency[year]![emoji] ?? 0) + 1;
    }

    // ✅ Find the most frequent mood for each year
    Map<int, Map<String, dynamic>> dominantMoods = {};
    moodFrequency.forEach((year, emojiCounts) {
      String dominantEmoji = emojiCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      int count = emojiCounts[dominantEmoji] ?? 0;

      dominantMoods[year] = {
        "emoji": dominantEmoji,
        "count": count,
        "title": moodLevels.entries.firstWhere(
              (e) => e.value[2]["emoji"] == dominantEmoji,
          orElse: () => MapEntry("Unknown", <Map<String, String>>[]),
        ).key
      };
    });

    return dominantMoods;
  }




  //   Map<String, String> _getDominantMoodPerDay() {
  //   Map<String, Map<String, int>> moodFrequency = {};
  //
  //   for (var log in widget.moodLogs) {
  //     String day = DateFormat('E').format(log.selectedDate);
  //     String emoji = getEmojiForMood(log.mood, log.intensityLevel);
  //
  //     if (!moodFrequency.containsKey(day)) {
  //       moodFrequency[day] = {};
  //     }
  //     moodFrequency[day]![emoji] = (moodFrequency[day]![emoji] ?? 0) + 1;
  //   }
  //
  //   Map<String, String> dominantMoods = {};
  //   moodFrequency.forEach((day, emojiCounts) {
  //     String dominantEmoji = emojiCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  //     dominantMoods[day] = dominantEmoji;
  //   });
  //
  //   return dominantMoods;
  // }
  //
  //
  // /// **🔹 Group Moods by Weeks and Get Dominant Mood Per Week**
  // Map<int, String> _getDominantMoodPerWeek() {
  //   Map<int, Map<String, int>> moodFrequency = {};
  //
  //   for (var log in widget.moodLogs) {
  //     int weekNum = _getWeekNumber(log.selectedDate); // ✅ Get week number (1, 2, 3, 4)
  //     String emoji = getEmojiForMood(log.mood, log.intensityLevel);
  //
  //     if (!moodFrequency.containsKey(weekNum)) {
  //       moodFrequency[weekNum] = {};
  //     }
  //     moodFrequency[weekNum]![emoji] = (moodFrequency[weekNum]![emoji] ?? 0) + 1;
  //   }
  //
  //   Map<int, String> dominantMoods = {};
  //   moodFrequency.forEach((week, emojiCounts) {
  //     String dominantEmoji = emojiCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  //     dominantMoods[week] = dominantEmoji; // ✅ Convert to 0-based index for graph
  //   });
  //
  //   return dominantMoods;
  // }

  /// **🔹 Get the Week Number of a Given Date (1-4)**
  int _getWeekNumber(DateTime date) {
    int dayOfMonth = date.day;
    return ((dayOfMonth - 1) ~/ 7) + 1; // ✅ Convert days into week numbers (1-4)
  }

  /// **Helper Function to Get Emoji for a Mood**
  String getEmojiForMood(String mood, int intensityLevel) {
    return moodLevels[mood]?[2]["emoji"] ?? "❓";
  }

  /// **🔹 Tooltip Widget**
  Widget _buildTooltip(MoodLog moodLog) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getEmojiForMood(moodLog.mood, moodLog.intensityLevel),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 5),
            Text(
              "${moodLog.mood} (${moodLog.intensityLevel})",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}




