import 'package:flutter/material.dart';

class CustomMoodBarGraph extends StatelessWidget {
  final Map<String, Map<String, int>> moodData; // {Trigger: {Mood: Count}}

  const CustomMoodBarGraph({Key? key, required this.moodData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: moodData.length * 60.0, // Adjust height dynamically
      child: CustomPaint(
        size: Size(double.infinity, moodData.length * 50),
        painter: MoodBarPainter(moodData),
      ),
    );
  }
}

class MoodBarPainter extends CustomPainter {
  final Map<String, Map<String, int>> moodData;
  MoodBarPainter(this.moodData);

  @override
  void paint(Canvas canvas, Size size) {
    final double barHeight = 40;
    final double spacing = 60;
    final double startX = 120;
    final double maxWidth = size.width - 150; // Allow space for labels

    final Paint borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke;

    int index = 0;
    double maxMoodCount = moodData.values
        .expand((emojiMap) => emojiMap.values)
        .fold(0, (prev, curr) => prev > curr ? prev : curr)
        .toDouble(); // Get max mood count for scaling

    moodData.forEach((trigger, moodCounts) {
      double totalWidth = moodCounts.values.fold(0, (sum, val) => sum + val).toDouble();
      double barWidth = (totalWidth / maxMoodCount) * maxWidth; // Normalize width
      double startY = index * spacing + 10;

      double currentX = startX;
      moodCounts.forEach((mood, count) {
        Paint paint = Paint()..color = _getMoodColor(mood);

        double segmentWidth = (count / totalWidth) * barWidth * 0.9;  // 0.9 reduces spacing issues


        // Draw horizontal bar
        Rect rect = Rect.fromLTWH(currentX, startY, segmentWidth, barHeight);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, borderPaint);

        // Draw emoji & count inside bar
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: "$mood $mood ($count)",
            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(currentX + 5, startY + 10));

        currentX += segmentWidth;
      });

      // Draw trigger label **beside the bar**
      TextPainter triggerPainter = TextPainter(
        text: TextSpan(
          text: trigger,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      triggerPainter.layout();
      triggerPainter.paint(canvas, Offset(10, startY + 10));

      index++;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  /// **Use the predefined mood color mapping**
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
