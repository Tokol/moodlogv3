import 'package:flutter/material.dart';
Widget buildMoodCard({
  required BuildContext context, // ✅ Pass context explicitly
  required String time,
  required Color faceColor,
  required dynamic icon, // Accepts both emoji and IconData
  required bool isLogged,
  String? moodTitle, // ✅ Add optional mood title
  required VoidCallback? onTap,
  required bool showArrow, // ✅ Add parameter to control arrow visibility
  required bool isSelectable, // ✅ Add parameter to check if time is selectable
}) {
  return GestureDetector(
    onTap: () {
      if (isSelectable) {
        // ✅ If time is selectable, call the provided onTap callback
        onTap?.call();
      } else {
        // ❌ If time is not selectable, show an alert
        showDialog(
          context: context, // ✅ Use the passed context
          builder: (context) => AlertDialog(
            title: const Text("Invalid Time"),
            content: const Text("You cannot log a mood for this time. The time limit has expired."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    },
    child: Card(
      elevation: showArrow ? 6 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isLogged ? faceColor.withOpacity(0.9) : Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: icon is IconData
                      ? Icon(icon, size: 32, color: isLogged ? faceColor : Colors.amber.shade700)
                      : Text(
                    icon, // ✅ Display emoji if available
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLogged ? "$time Mood Logged" : "+ Log Mood for $time",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isLogged ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (isLogged && moodTitle != null) // ✅ Show mood title if logged
                      Text(
                        moodTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (showArrow) // ✅ Conditionally show arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: isLogged ? Colors.white : Colors.black54,
              ),
          ],
        ),
      ),
    ),
  );
}