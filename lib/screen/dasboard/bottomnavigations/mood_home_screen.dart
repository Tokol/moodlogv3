import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodlog/models/mood_log_models.dart';
import '../../../database/database_helper.dart';
import '../../../models/to_do_models.dart';
import '../../../models/weekly_to_do.dart';
import '../../../services/mood_forecast_service.dart';
import '../../../services/prompt_response.dart';
import '../../../utils/const_files.dart';
import '../../../widgets/to_do_section.dart';
import '../mood_selection_screen.dart';

class MoodHomeScreen extends StatefulWidget {
  const MoodHomeScreen({Key? key}) : super(key: key);

  @override
  State<MoodHomeScreen> createState() => _MoodHomeScreenState();
}

class _MoodHomeScreenState extends State<MoodHomeScreen> {
  List<WeeklyTodo> aiWeeklyTodos = [];
  bool isLoadingTodos = true;
  List<MoodForecast> forecastData = [];
  bool isLoadingForecast = false;

  @override
  void initState() {
    super.initState();
    loadTodosFromAI();
    loadForecastFromDB();
  }

  Future<void> loadTodosFromAI() async {
    setState(() => isLoadingTodos = true);
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<TodoItem> existingTodos = await DatabaseHelper.instance.getTodoItemsByDate(today);

    if (existingTodos.isNotEmpty) {
      DateTime now = DateTime.now();
      String startDate = DateFormat('yyyy-MM-dd').format(now);
      String endDate = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 6)));
      List<TodoItem> allTodos = await DatabaseHelper.instance.getTodoItemsInDateRange(startDate, endDate);

      Map<String, List<TodoItem>> grouped = {};
      for (var item in allTodos) {
        grouped.putIfAbsent(item.date, () => []).add(item);
      }

      List<WeeklyTodo> todos = grouped.entries.map((entry) {
        DateTime date = DateTime.parse(entry.key);
        String dayLabel = DateFormat('EEEE d MMMM').format(date);
        return WeeklyTodo(day: dayLabel, tasks: entry.value);
      }).toList();

      setState(() {
        aiWeeklyTodos = todos;
        isLoadingTodos = false;
      });
      return;
    }

    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(days: 14));
    String startDate = DateFormat('yyyy-MM-dd').format(start);
    String endDate = DateFormat('yyyy-MM-dd').format(now);
    List<MoodLog> logs = await DatabaseHelper.instance.getMoodsInRange(startDate, endDate);

    if (logs.isEmpty) {
      setState(() => isLoadingTodos = false);
      return;
    }

    Map<String, List<String>> moodMap = {"Morning": [], "Afternoon": [], "Evening": [], "Night": []};
    for (var log in logs) {
      DateTime time = _parseTime(log.selectedTime);
      if (time.hour >= 0 && time.hour < 4) moodMap["Night"]!.add(log.mood);
      else if (time.hour >= 4 && time.hour < 12) moodMap["Morning"]!.add(log.mood);
      else if (time.hour >= 12 && time.hour < 17) moodMap["Afternoon"]!.add(log.mood);
      else moodMap["Evening"]!.add(log.mood);
    }

    List<WeeklyTodo> todosFromAI = await fetchWeeklyTodosFromAI(moodMap);
    for (var weeklyTodo in todosFromAI) {
      String parsedDate = _parseDateFromDayLabel(weeklyTodo.day);
      for (var item in weeklyTodo.tasks) {
        final todoWithDate = item.toMap()..['date'] = parsedDate;
        await DatabaseHelper.instance.insertTodoItem(TodoItem.fromMap(todoWithDate));
      }
    }

    setState(() {
      aiWeeklyTodos = todosFromAI;
      isLoadingTodos = false;
    });
  }

  Future<void> loadForecastFromDB() async {
    final latestForecast = await DatabaseHelper.instance.getLatestForecast();
    if (latestForecast != null) {
      setState(() => forecastData = _parseForecastJson(latestForecast['forecast'] as String));
    }
  }


  List<MoodForecast> _parseForecastJson(String jsonString) {
    try {
      final List<dynamic> parsed = jsonDecode(jsonString);
      return parsed.map((item) => MoodForecast.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print("⚠️ JSON parsing failed: $e");
      return [MoodForecast(day: todayFormatted(), mood: "Error", reason: '', suggestion: '', todoImpact: '',)];
    }
  }

  Future<void> refreshMoodForecast() async {
    setState(() => isLoadingForecast = true);
    List<MoodForecast> newForecast = await fetchMoodForecast(forceRefresh: true);
    setState(() {
      forecastData = newForecast;
      isLoadingForecast = false;
    });
  }

  DateTime _parseTime(String timeStr) {
    try {
      timeStr = timeStr.replaceAll(RegExp(r'\s+'), ' ').trim();
      return DateFormat('h a').parse(timeStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _parseDateFromDayLabel(String dayLabel) {
    DateTime now = DateTime.now();
    DateTime parsedDate = DateFormat('EEEE d MMMM').parse(dayLabel);
    parsedDate = DateTime(now.year, parsedDate.month, parsedDate.day);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }
  void _onMoodTap(BuildContext context, String time, List<Map<String, dynamic>> moodLogs) async {
    final existingMood = moodLogs.firstWhere((log) => log['selectedTime'] == time, orElse: () => {});
    if (existingMood.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Already Logged"),
          content: const Text("You have already logged a mood for this time."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
      return;
    }

    if (isTimeSelectable(time)) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MoodSelectionScreen(selectedTime: time)),
      );
      if (result == true) setState(() {});
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Time Restriction"),
          content: const Text("Time limit exceeded!"),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchMoodLogsForToday(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading mood data!", style: TextStyle(color: Colors.red)));
              }

              final moodLogs = snapshot.data ?? [];
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      "Mood Today",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                        shadows: [Shadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                    ),
                    centerTitle: true,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(20),
                      child: Text(
                        DateFormat('MMMM d, y').format(DateTime.now()),
                        style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMoodSection(moodLogs, context),
                          const SizedBox(height: 24),
                          _buildTodoSection(),
                          const SizedBox(height: 24),
                          _buildForecastSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSection(List<Map<String, dynamic>> moodLogs, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How are you feeling?",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
        ),
        const SizedBox(height: 12),
        ...["7 AM", "2 PM", "8 PM"].map((time) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildMoodCard(moodLogs, time, context),
        )),
      ],
    );
  }

  Widget _buildMoodCard(List<Map<String, dynamic>> moodLogs, String time, BuildContext context) {
    final moodLog = moodLogs.firstWhere((log) => log['selectedTime'] == time, orElse: () => {});
    final isLogged = moodLog.isNotEmpty;
    final isSelectable = isTimeSelectable(time);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLogged
              ? [Colors.green.shade300, Colors.green.shade500]
              : isSelectable
              ? [Colors.blue.shade200, Colors.blue.shade400]
              : [Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Text(
            isLogged ? getEmojiForMood(moodLog['mood'], moodLog['intensityLevel']) : isSelectable ? "➕" : "⏳",
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          isLogged ? getMoodTitle(moodLog['mood'], moodLog['intensityLevel']) : "Log your mood",
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(time, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        trailing: isSelectable ? const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16) : null,
        onTap: () => _onMoodTap(context, time, moodLogs),
      ),
    );
  }

  Widget _buildTodoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Tasks",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
        ),
        const SizedBox(height: 12),
        isLoadingTodos
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : aiWeeklyTodos.isEmpty
            ? Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text("No tasks yet. Log your mood to get started!", style: TextStyle(color: Colors.grey)),
        )
            : TodoSection(weeklyTodos: aiWeeklyTodos),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mood Forecast",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blueAccent),
              onPressed: refreshMoodForecast,
              tooltip: "Refresh Forecast",
            ),
          ],
        ),
        const SizedBox(height: 12),
        isLoadingForecast
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : forecastData.isEmpty
            ? Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade200, Colors.blue.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "No forecast yet. Tap refresh to generate one.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        )
            : SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: forecastData.map((forecast) => _buildForecastChip(forecast)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastChip(MoodForecast forecast) {
    final moodColor = _getMoodColor(forecast.mood);
    return GestureDetector(
      onTap: () => _showForecastDetails(context, forecast),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [moodColor, moodColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              forecast.day,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              forecast.mood,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showForecastDetails(BuildContext context, MoodForecast forecast) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "${forecast.day} - ${forecast.mood}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Reason", forecast.reason),
            const SizedBox(height: 8),
            _buildDetailRow("Suggestion", forecast.suggestion),
            const SizedBox(height: 8),
            _buildDetailRow("To-Do Impact", forecast.todoImpact),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: Colors.purple.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple.shade700, fontSize: 14),
          ),
          TextSpan(
            text: value.isEmpty ? "N/A" : value,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case "happy":
        return Colors.green.shade400;
      case "stressed":
      case "anxiety":
        return Colors.red.shade400;
      case "calm":
        return Colors.blue.shade400;
      case "tired":
        return Colors.grey.shade400;
      default:
        return Colors.purple.shade400;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMoodLogsForToday() async {
    final String today = DateTime.now().toIso8601String().split('T')[0];
    List<MoodLog> moodLogs = await DatabaseHelper.instance.getMoodsByDate(today);
    return moodLogs.map((mood) => mood.toMap()).toList();
  }

  String getEmojiForMood(String mood, int intensity) => moodLevels[mood]?[intensity - 1]["emoji"] ?? "❓";
  String getMoodTitle(String mood, int intensity) => moodLevels[mood]?[intensity - 1]["title"] ?? "Unknown Mood";
  bool isTimeSelectable(String time) => true; // Placeholder
}