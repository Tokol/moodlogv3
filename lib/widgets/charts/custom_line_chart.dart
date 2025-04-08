import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodlog/models/mood_log_models.dart';

import 'dart:ui' as ui;

import '../../utils/const_files.dart';

class CustomLineChart extends StatelessWidget {
  final List<MoodLog> moodData; // List of moods

  const CustomLineChart({Key? key, required this.moodData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // ✅ Chart height
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomPaint(
          painter: LineChartPainter(moodData),
          child: Container(),
        ),
      ),
    );
  }
}

/// ✅ **Helper Function: Get Emoji for a Mood**
String getEmojiForMood(String mood, int intensityLevel) {
  if (moodLevels.containsKey(mood)) {
    return moodLevels[mood]?[intensityLevel - 1]["emoji"] ?? "❓";
  }
  return "❓"; // Default emoji if mood not found
}

class LineChartPainter extends CustomPainter {
  final List<MoodLog> moodData;

  LineChartPainter(this.moodData);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final double chartWidth = size.width;
    final double chartHeight = size.height;
    final double spacing = chartWidth / (moodData.length - 1);

    Path path = Path();

    for (int i = 0; i < moodData.length; i++) {
      double x = i * spacing;
      double y = chartHeight - (chartHeight / 5) * moodData[i].intensityLevel; // Convert mood level to Y position

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.cubicTo(x - spacing / 2, y, x - spacing / 2, y, x, y); // ✅ Smooth curve transition
      }

      // ✅ Get Correct Emoji
      String emoji = getEmojiForMood(moodData[i].mood, moodData[i].intensityLevel);

      // ✅ Draw Emoji at Data Point (Perfectly Centered)
      final textPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: const TextStyle(fontSize: 22),
        ),
        textDirection: ui.TextDirection.ltr// ✅ Correct Usage
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), y - (textPainter.height / 2))); // ✅ Correct positioning

      // ✅ Draw Weekday Labels Below the Chart
      final textPainterDay = TextPainter(
        text: TextSpan(
          text: DateFormat('E').format(moodData[i].selectedDate), // ✅ Show weekday (Sun, Mon, Tue)
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        textDirection: ui.TextDirection.ltr,

      );
      textPainterDay.layout();
      textPainterDay.paint(canvas, Offset(x - (textPainterDay.width / 2), chartHeight + 5)); // ✅ Position below the chart
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
