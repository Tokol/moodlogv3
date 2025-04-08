import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/to_do_models.dart';
import '../models/weekly_to_do.dart';
import 'to_do_card.dart';

class TodoSection extends StatefulWidget {
  final List<WeeklyTodo> weeklyTodos;

  const TodoSection({Key? key, required this.weeklyTodos}) : super(key: key);

  @override
  _TodoSectionState createState() => _TodoSectionState();
}

class _TodoSectionState extends State<TodoSection> {
  @override
  Widget build(BuildContext context) {
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final todaysTasks = widget.weeklyTodos
        .expand((weeklyTodo) => weeklyTodo.tasks)
        .where((task) {
      try {
        final taskDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(task.date));
        return taskDate == todayDate;
      } catch (e) {
        print("Error parsing task date: ${task.date}, Error: $e");
        return false;
      }
    })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today - $formattedDate",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
              ),
              const SizedBox(height: 8),
              if (todaysTasks.isEmpty)
                const Text("No tasks for today.", style: TextStyle(color: Colors.grey))
              else
                ...todaysTasks.map((task) => TodoCard(
                  task: task,
                  onCheckboxChanged: (value) => setState(() => task.isCompleted = value ?? false),
                )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          collapsedBackgroundColor: Colors.white.withOpacity(0.9),
          backgroundColor: Colors.white.withOpacity(0.9),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Weekly Tasks",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          children: widget.weeklyTodos.map((weeklyTodo) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.blue.shade50,
                backgroundColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(
                  weeklyTodo.day,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
                ),
                children: weeklyTodo.tasks.map((task) {
                  return TodoCard(
                    task: task,
                    onCheckboxChanged: (value) => setState(() => task.isCompleted = value ?? false),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}