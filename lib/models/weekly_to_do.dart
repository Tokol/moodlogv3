import 'package:moodlog/models/to_do_models.dart';

class WeeklyTodo {
  final String day; // Day of the week (e.g., "Monday")
  final List<TodoItem> tasks; // List of tasks for the day

  WeeklyTodo({
    required this.day,
    required this.tasks,
  });
}