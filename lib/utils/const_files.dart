import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/to_do_models.dart';
import '../models/weekly_to_do.dart';

final Map<String, List<String>> categorizedMoodAffectingFactors = {
  "💼 Work & Productivity": [
    'Work-related',
    'Work Environment',
    'Time Management',
    'Procrastination'
  ],
  "❤️ Personal Life & Relationships": [
    'Relationship',
    'Family',
    'Friends',
    'Social Life',
    'Social Media'
  ],
  "🧘 Health & Well-being": [
    'Sleep',
    'Diet',
    'Physical Health',
    'Mental Health',
    'Exercise'
  ],
  "📈 Financial & Career": [
    'Finance',
    'Financial Stress',
    'Education',
    'Personal Goals'
  ],
  "🌍 Environment & External Factors": [
    'Weather',
    'Seasonal Changes',
    'Current Events',
    'Technology/Device Use'
  ],
  "🎨 Lifestyle & Interests": [
    'Movie',
    'Hobbies',
    'Travel',
    'Creativity',
    'Spirituality'
  ],
  "🛌 Sleep & Recovery": [
    'Sleep Quality'
  ]
};


final List<Map<String, dynamic>> moods = [
  {"label": "Angry", "emoji": Icons.sentiment_very_dissatisfied, "color": Colors.red},
  {"label": "Sad", "emoji": Icons.sentiment_dissatisfied, "color": Colors.amber.shade700}, // Changed to Yellow
  {"label": "Anxious", "emoji": Icons.sentiment_neutral, "color": Colors.blue}, // Changed to Blue
  {"label": "Calm", "emoji": Icons.sentiment_satisfied, "color": Colors.green},
  {"label": "Happy", "emoji": Icons.sentiment_very_satisfied, "color": Colors.orange},
];


final Map<String, List<Map<String, String>>> moodLevels = {
  "Angry": [
    {"title": "Slightly Angry", "emoji": "😤"},
    {"title": "Mildly Angry", "emoji": "😠"},
    {"title": "Moderately Angry", "emoji": "😡"},
    {"title": "Highly Angry", "emoji": "🤬"},
    {"title": "Extremely Angry", "emoji": "💢"},
  ],
  "Sad": [
    {"title": "Slightly Sad", "emoji": "😞"},
    {"title": "Mildly Sad", "emoji": "😔"},
    {"title": "Moderately Sad", "emoji": "😢"},
    {"title": "Highly Sad", "emoji": "😭"},
    {"title": "Extremely Sad", "emoji": "💔"},
  ],
  "Anxious": [
    {"title": "Slightly Anxious", "emoji": "😟"},
    {"title": "Mildly Anxious", "emoji": "😰"},
    {"title": "Moderately Anxious", "emoji": "😨"},
    {"title": "Highly Anxious", "emoji": "😱"},
    {"title": "Extremely Anxious", "emoji": "🥶"},
  ],
  "Calm": [
    {"title": "Slightly Calm", "emoji": "🙂"},
    {"title": "Mildly Calm", "emoji": "😊"},
    {"title": "Moderately Calm", "emoji": "😌"},
    {"title": "Highly Calm", "emoji": "😴"},
    {"title": "Extremely Calm", "emoji": "🧘"},
  ],
  "Happy": [
    {"title": "Slightly Happy", "emoji": "😀"},
    {"title": "Mildly Happy", "emoji": "😁"},
    {"title": "Moderately Happy", "emoji": "😃"},
    {"title": "Highly Happy", "emoji": "😂"},
    {"title": "Extremely Happy", "emoji": "🤩"},
  ],
};


bool isTimeSelectable(String moodTime) {
  DateTime now = DateTime.now();
  DateTime selectedTime = _parseMoodTime(moodTime, now);

  print("selected time is $selectedTime");
  print("now is $now");

  // ✅ Allow if moodTime is within 30 minutes before current time
  // ✅ Allow if moodTime is equal to current time
  // ✅ Allow if moodTime is within 2 hours after current time
  return now.isAfter(selectedTime.subtract(const Duration(minutes: 30))) && // Within 30 minutes before
      now.isBefore(selectedTime.add(const Duration(hours: 2))); // Within 2 hours after
}

DateTime _parseMoodTime(String moodTime, DateTime now) {
  // Parse the moodTime string (e.g., "7 AM") into a DateTime object
  final timeFormat = DateFormat('h a'); // Example format: "7 AM"
  final parsedTime = timeFormat.parse(moodTime);

  // Combine with the current date
  return DateTime(
    now.year,
    now.month,
    now.day,
    parsedTime.hour,
    parsedTime.minute,
  );
}
IconData getTriggerIcon(String trigger) {
  // Work & Productivity
  if (trigger == 'Work-related' || trigger == 'Work Environment') {
    return Icons.work;
  }
  if (trigger == 'Time Management') {
    return Icons.access_time;
  }
  if (trigger == 'Procrastination') {
    return Icons.timer_off;
  }

  // Personal Life & Relationships
  if (trigger == 'Relationship') {
    return Icons.favorite;
  }
  if (trigger == 'Family') {
    return Icons.family_restroom;
  }
  if (trigger == 'Friends') {
    return Icons.people;
  }
  if (trigger == 'Social Life') {
    return Icons.celebration;
  }
  if (trigger == 'Social Media') {
    return Icons.thumb_up;
  }

  // Health & Well-being
  if (trigger == 'Sleep' || trigger == 'Sleep Quality') {
    return Icons.bedtime;
  }
  if (trigger == 'Diet') {
    return Icons.restaurant;
  }
  if (trigger == 'Physical Health') {
    return Icons.fitness_center;
  }
  if (trigger == 'Mental Health') {
    return Icons.psychology;
  }
  if (trigger == 'Exercise') {
    return Icons.directions_run;
  }

  // Financial & Career
  if (trigger == 'Finance' || trigger == 'Financial Stress') {
    return Icons.attach_money;
  }
  if (trigger == 'Education') {
    return Icons.school;
  }
  if (trigger == 'Personal Goals') {
    return Icons.flag;
  }

  // Environment & External Factors
  if (trigger == 'Weather') {
    return Icons.wb_sunny;
  }
  if (trigger == 'Seasonal Changes') {
    return Icons.ac_unit;
  }
  if (trigger == 'Current Events') {
    return Icons.newspaper;
  }
  if (trigger == 'Technology/Device Use') {
    return Icons.phone_android;
  }

  // Lifestyle & Interests
  if (trigger == 'Movie') {
    return Icons.movie;
  }
  if (trigger == 'Hobbies') {
    return Icons.sports_esports;
  }
  if (trigger == 'Travel') {
    return Icons.flight;
  }
  if (trigger == 'Creativity') {
    return Icons.brush;
  }
  if (trigger == 'Spirituality') {
    return Icons.spa;
  }

  // Default icon for unknown triggers
  return Icons.help_outline;
}


IconData getLocationIcon(String location) {
  switch (location) {
  // Predefined Locations
    case "Home":
      return Icons.home; // 🏠
    case "Office":
      return Icons.work; // 🏢
    case "School/College":
      return Icons.school; // 🏫
    case "Friend Gathering":
      return Icons.people; // 👥
    case "Family Gathering":
      return Icons.family_restroom; // 👨‍👩‍👧‍👦

  // Custom Locations (added by users)
    case "Cafe":
      return Icons.local_cafe; // ☕
    case "Gym":
      return Icons.fitness_center; // 🏋️
    case "Dating":
      return Icons.favorite; // ❤️
    case "Park":
      return Icons.park; // 🌳
    case "Restaurant":
      return Icons.restaurant; // 🍽️
    case "Travel":
      return Icons.flight; // ✈️
    case "Shopping":
      return Icons.shopping_cart; // 🛒
    case "Movie":
      return Icons.movie; // 🎬
    case "Concert":
      return Icons.music_note; // 🎵
    case "Beach":
      return Icons.beach_access; // 🏖️
    case "Hospital":
      return Icons.local_hospital; // 🏥
    case "Library":
      return Icons.library_books; // 📚
    case "Temple":
      return Icons.account_balance; // ⛪
    case "Gaming":
      return Icons.sports_esports; // 🎮
    case "Hiking":
      return Icons.directions_walk; // 🥾
    case "Party":
      return Icons.celebration; // 🎉
    case "Wedding":
      return Icons.people_outline; // 👰
    case "Workout":
      return Icons.directions_run; // 🏃‍♂️
    case "Yoga":
      return Icons.self_improvement; // 🧘
    case "Other":
      return Icons.location_on; // Default icon for "Other"

  // Default for unknown locations
    default:
      return Icons.location_on; // 📍
  }
}


