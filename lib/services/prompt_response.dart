import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/to_do_models.dart';
import '../models/weekly_to_do.dart';
import 'open_ai_service.dart';

Future<List<WeeklyTodo>> fetchWeeklyTodosFromAI(Map<String, List<String>> moodMap) async {
  String todayFormatted = DateFormat('EEEE d MMMM').format(DateTime.now());

  try {
    String moodSummary = _generateMoodSummary(moodMap);
    String prompt = _buildAIPrompt(moodSummary, todayFormatted);
    String aiResponse = await _requestAIWithRetry(prompt);
    return _parseAIResponse(aiResponse, todayFormatted);
  } catch (e) {
    print("❌ Final error in fetchWeeklyTodosFromAI: $e");
    return _createFallbackWeeklyTodos(todayFormatted);
  }
}

String _generateMoodSummary(Map<String, List<String>> moodMap) {
  return moodMap.entries.map((entry) {
    Map<String, int> moodCount = {};
    for (var mood in entry.value) {
      moodCount[mood] = (moodCount[mood] ?? 0) + 1;
    }
    String counts = moodCount.entries
        .map((e) => "${e.key} (${e.value}x)")
        .join(", ");
    return "${entry.key}: $counts";
  }).join("\n");
}

String _buildAIPrompt(String moodSummary, String todayFormatted) {
  return """
Based on the user's mood pattern over the past 14 days:
$moodSummary

STRICT RULES:
1. Response must be pure JSON only
2. Include exactly 7 days starting from $todayFormatted
3. Each day has 2-3 tasks with these exact fields:
   - title (12-60 chars)
   - description (30-120 chars)
   - duration (e.g. "15 minutes")
   - category (e.g. "Mental Health")
   - url (valid YouTube URL)
   - tags (array of 3 strings)

4. EXAMPLE FORMAT:
{
  "Monday 7 April": [
    {
      "title": "Morning meditation",
      "description": "Start your day with a 10-minute mindfulness exercise",
      "duration": "10 minutes",
      "category": "Mindfulness",
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "tags": ["calm", "focus", "morning"]
    }
  ]
}
5. VALIDATION REQUIREMENTS:
- All brackets must be properly closed
- No truncated strings
- All URLs must be complete
- Total response under 3000 tokens

Return ONLY the JSON object with no additional text or markdown.
""";
}

Future<String> _requestAIWithRetry(String prompt, {int maxRetries = 3}) async {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      String response = await OpenAIService.requestAI(prompt);
      if (_validateAIResponse(response)) {
        return response;
      }
      print("⚠️ Attempt ${attempt + 1}: Invalid response structure");
      if (attempt == maxRetries - 1) return response;
    } catch (e) {
      print("⚠️ Attempt ${attempt + 1} failed: $e");
      if (attempt == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 1 * (attempt + 1)));
    }
  }
  throw Exception("All retry attempts failed");
}

bool _validateAIResponse(String response) {
  response = response.trim();
  return response.startsWith('{') &&
      response.endsWith('}') &&
      response.length > 100 &&
      response.contains('"title":') &&
      response.contains('"description":');
}

List<WeeklyTodo> _parseAIResponse(String aiResponse, String todayFormatted) {
  try {
    String cleanedResponse = _cleanAIResponse(aiResponse);

    try {
      return _parseCompleteResponse(cleanedResponse);
    } catch (e) {
      print("⚠️ Complete parse failed, trying partial: $e");
      return _parsePartialResponse(cleanedResponse, todayFormatted);
    }
  } catch (e) {
    print("❌ Both complete and partial parsing failed: $e");
    return _createFallbackWeeklyTodos(todayFormatted);
  }
}

String _cleanAIResponse(String response) {
  response = response.trim();

  if (response.startsWith('```json')) {
    response = response.substring(7);
  }
  if (response.startsWith('```')) {
    response = response.substring(3);
  }
  if (response.endsWith('```')) {
    response = response.substring(0, response.length - 3);
  }

  if (!response.endsWith('}') && response.contains('}')) {
    response = response.substring(0, response.lastIndexOf('}') + 1);
  }

  if (response.contains('[') && !response.contains(']')) {
    response = response + ']';
  }

  if (response.contains('{') && !response.contains('}')) {
    response = response + '}';
  }

  return response;
}

List<WeeklyTodo> _parseCompleteResponse(String response) {
  try {
    Map<String, dynamic> parsedJson = jsonDecode(response);
    List<WeeklyTodo> weeklyTodos = [];

    parsedJson.forEach((day, tasksJson) {
      try {
        DateTime taskDate = _parseTaskDate(day);
        String formattedDate = DateFormat('yyyy-MM-dd').format(taskDate);

        List<TodoItem> tasks = (tasksJson as List).map((task) {
          return TodoItem(
            title: task['title']?.toString() ?? 'Untitled Task',
            description: task['description']?.toString() ?? '',
            url: task['url']?.toString() ?? '',
            thumbnailUrl: getThumbnailFromYouTube(task['url']?.toString() ?? ''),
            duration: task['duration']?.toString() ?? '',
            category: task['category']?.toString() ?? '',
            date: formattedDate,
            tags: (task['tags'] is List)
                ? List<String>.from((task['tags'] as List).map((e) => e.toString()))
                : [],
          );
        }).toList();

        weeklyTodos.add(WeeklyTodo(day: day, tasks: tasks));
      } catch (e) {
        print("⚠️ Error parsing day $day: $e");
      }
    });

    if (weeklyTodos.isEmpty) {
      throw Exception("No valid days found in response");
    }

    return weeklyTodos;
  } catch (e) {
    print("❌ Complete parse error: $e");
    rethrow;
  }
}

List<WeeklyTodo> _parsePartialResponse(String response, String todayFormatted) {
  try {
    final dayBlockRegex = RegExp(
      r'"(\w+ \d{1,2} \w+)"\s*:\s*\[(.*?)\](?=,\s*"\w+ \d{1,2} \w+"|})',
      dotAll: true,
    );

    final matches = dayBlockRegex.allMatches(response);
    Map<String, List<TodoItem>> parsedTasks = {};

    for (final match in matches) {
      final day = match.group(1);
      final taskJsonStr = '[${match.group(2)}]';

      if (day == null || taskJsonStr.isEmpty) continue;

      try {
        final parsedList = jsonDecode(taskJsonStr);
        if (parsedList is List) {
          final taskItems = parsedList.map<TodoItem>((task) {
            if (task is! Map) return TodoItem(title: "title", description: "description", url: "url", thumbnailUrl: "thumbnailUrl", duration: "duration", category: "category", tags: [], date: "date");

            return TodoItem(
              title: task['title']?.toString() ?? 'Untitled Task',
              description: task['description']?.toString() ?? '',
              url: task['url']?.toString() ?? '',
              thumbnailUrl: getThumbnailFromYouTube(task['url']?.toString() ?? ''),
              duration: task['duration']?.toString() ?? '',
              category: task['category']?.toString() ?? '',
              date: DateFormat('yyyy-MM-dd').format(_parseTaskDate(day)),
              tags: (task['tags'] is List)
                  ? List<String>.from((task['tags'] as List).map((e) => e.toString()))
                  : [],
            );
          }).where((task) => task != null).cast<TodoItem>().toList();

          if (taskItems.isNotEmpty) {
            parsedTasks[day] = taskItems;
          }
        }
      } catch (e) {
        print("⚠️ Skipping malformed task list for $day: $e");
      }
    }

    if (parsedTasks.isEmpty) {
      throw Exception("No valid day blocks found");
    }

    return parsedTasks.entries.map((e) => WeeklyTodo(day: e.key, tasks: e.value)).toList();
  } catch (e) {
    print("❌ Partial parse failed: $e");
    return _createFallbackWeeklyTodos(todayFormatted);
  }
}
List<WeeklyTodo> _createFallbackWeeklyTodos(String todayFormatted) {
  return [
    WeeklyTodo(
      day: todayFormatted,
      tasks: [
        TodoItem(
          title: 'Take a deep breath',
          description: 'Practice deep breathing for 5 minutes',
          url: 'https://www.youtube.com/watch?v=tEmt1Znux58',
          thumbnailUrl: getThumbnailFromYouTube('https://www.youtube.com/watch?v=tEmt1Znux58'),
          duration: '5 minutes',
          category: 'Mindfulness',
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          tags: ['breathing', 'calm', 'quick'],
        )
      ],
    )
  ];
}

DateTime _parseTaskDate(String day) {
  try {
    return DateFormat('EEEE d MMMM').parse(day);
  } catch (e) {
    print("⚠️ Failed to parse date '$day', using today as fallback");
    return DateTime.now();
  }
}

String getThumbnailFromYouTube(String url) {
  try {
    if (url.isEmpty || url.length < 20) return "";

    Uri uri = Uri.parse(url);
    String? videoId = uri.queryParameters['v'];

    if (videoId == null && uri.host.contains("youtu.be")) {
      videoId = uri.pathSegments.first;
    }

    return videoId != null ? "https://img.youtube.com/vi/$videoId/0.jpg" : "";
  } catch (e) {
    print("⚠️ YouTube URL parsing error: $e");
    return "";
  }
}