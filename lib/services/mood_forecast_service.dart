import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:moodlog/database/database_helper.dart';
import 'package:moodlog/models/mood_log_models.dart';
import 'package:moodlog/models/to_do_models.dart';
import 'open_ai_service.dart';

class MoodForecast {
  final String day;
  final String mood;
  final String reason;
  final String suggestion;
  final String todoImpact;

  MoodForecast({
    required this.day,
    required this.mood,
    required this.reason,
    required this.suggestion,
    required this.todoImpact,
  });

  factory MoodForecast.fromJson(Map<String, dynamic> json) {
    return MoodForecast(
      day: json['day'] ?? '',
      mood: json['mood'] ?? 'Unknown',
      reason: json['reason'] ?? '',
      suggestion: json['suggestion'] ?? '',
      todoImpact: json['todoImpact'] ?? '',
    );
  }
}

Future<List<MoodForecast>> fetchMoodForecast({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final latestForecast = await DatabaseHelper.instance.getLatestForecast();
    if (latestForecast != null) {
      return _parseForecastJson(latestForecast['forecast'] as String);
    }
  }

  DateTime now = DateTime.now();
  String startDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 14)));
  String endDate = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 6)));
  List<MoodLog> moodLogs = await DatabaseHelper.instance.getMoodsInRange(startDate, DateFormat('yyyy-MM-dd').format(now));
  List<TodoItem> allTodos = await DatabaseHelper.instance.getTodoItemsInDateRange(startDate, endDate);

  if (moodLogs.isEmpty || allTodos.isEmpty) {
    return [MoodForecast(day: '', mood: "N/A", reason: "Not enough data", suggestion: "Log moods and tasks", todoImpact: "")];
  }

  String moodSummary = _generateMoodSummary(moodLogs);
  String todoSummary = _generateTodoSummary(allTodos);
  String todayFormatted = DateFormat('EEEE d MMMM').format(now);

  String prompt = _buildForecastPrompt(moodSummary, todoSummary, todayFormatted);
  String aiResponse = await _requestAIWithRetry(prompt);
  String cleanedResponse = _cleanAIResponse(aiResponse);

  await DatabaseHelper.instance.saveForecast(cleanedResponse);
  return _parseForecastJson(cleanedResponse);
}

String _generateMoodSummary(List<MoodLog> moodLogs) {
  Map<String, List<String>> moodMap = {"Morning": [], "Afternoon": [], "Evening": [], "Night": []};
  for (var log in moodLogs) {
    DateTime time = DateFormat('h a').parse(log.selectedTime);
    String mood = "${log.mood} (Intensity: ${log.intensityLevel}, Factors: ${log.moodFactors.join(', ')})";
    if (time.hour >= 0 && time.hour < 4) moodMap["Night"]!.add(mood);
    else if (time.hour >= 4 && time.hour < 12) moodMap["Morning"]!.add(mood);
    else if (time.hour >= 12 && time.hour < 17) moodMap["Afternoon"]!.add(mood);
    else moodMap["Evening"]!.add(mood);
  }
  return moodMap.entries.map((entry) => "${entry.key}: ${entry.value.isEmpty ? 'None' : entry.value.join(', ')}").join("\n");
}

String _generateTodoSummary(List<TodoItem> todos) {
  Map<String, List<String>> todoMap = {};
  for (var todo in todos) {
    String status = todo.isCompleted ? "Completed" : "Not Completed";
    String entry = "${todo.title} ($status, Category: ${todo.category}, Duration: ${todo.duration})";
    todoMap.putIfAbsent(todo.date, () => []).add(entry);
  }
  return todoMap.entries.map((entry) => "${entry.key}: ${entry.value.join(', ')}").join("\n");
}

String _buildForecastPrompt(String moodSummary, String todoSummary, String todayFormatted) {
  return """
Based on the user's mood pattern over the past 14 days and their to-do task completion, provide a mood forecast for the next 7 days starting from $todayFormatted. Return a strict JSON response with:

- An array of 7 objects, one for each day.
- Each object must have:
  - "day": string (e.g., "Tue 8 Apr")
  - "mood": string (e.g., "Happy", "Stressed")
  - "reason": string (short explanation, max 15 words)
  - "suggestion": string (short advice, max 15 words)
  - "todoImpact": string (effect of completing a task, max 15 words)

**Mood Summary:**
$moodSummary

**To-Do Summary:**
$todoSummary

Example:
[
  {"day": "Tue 8 Apr", "mood": "Stressed", "reason": "Busy morning schedule", "suggestion": "Start with meditation", "todoImpact": "'Meditation' calms you"}
]

Return ONLY the JSON array, no extra text or markdown. Limit response to 500 tokens.
""";
}

Future<String> _requestAIWithRetry(String prompt, {int maxRetries = 3}) async {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      String response = await OpenAIService.requestAI(prompt);
      if (response.trim().isNotEmpty) return response;
      print("⚠️ Attempt ${attempt + 1}: Empty or invalid response");
      if (attempt == maxRetries - 1) return response;
    } catch (e) {
      print("⚠️ Attempt ${attempt + 1} failed: $e");
      if (attempt == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 1 * (attempt + 1)));
    }
  }
  throw Exception("All retry attempts failed");
}

String _cleanAIResponse(String response) {
  response = response.trim();
  if (response.startsWith('```json')) response = response.substring(7);
  if (response.startsWith('```')) response = response.substring(3);
  if (response.endsWith('```')) response = response.substring(0, response.length - 3);
  return response.isEmpty ? '[]' : response;
}

List<MoodForecast> _parseForecastJson(String jsonString) {
  try {
    final List<dynamic> parsed = jsonDecode(jsonString);
    return parsed.map((item) => MoodForecast.fromJson(item as Map<String, dynamic>)).toList();
  } catch (e) {
    print("⚠️ JSON parsing failed: $e");
    return [MoodForecast(day: todayFormatted(), mood: "Error", reason: "Failed to parse", suggestion: "Try refreshing", todoImpact: "")];
  }
}

String todayFormatted() => DateFormat('EEE d MMM').format(DateTime.now());