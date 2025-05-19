import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moodlog/screen/auth/signin.dart';
import 'package:moodlog/screen/auth/signup.dart';
import 'package:moodlog/screen/dasboard/dasboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'database/database_helper.dart';
import 'models/mood_log_models.dart';
import 'mood_form.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await dotenv.load();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(initialRoute: isLoggedIn ? 'dash' : 'signin'));
}


Future<void> insertDummyData() async {
  final db = await DatabaseHelper.instance.database;

  // ✅ Possible moods
  List<String> moods = ["Happy", "Sad", "Angry", "Anxious", "Calm"];

  // ✅ Possible locations
  List<String> locations = [
    "Home", "Office", "School/College", "Friend Gathering", "Family Gathering",
    "Date", "Movie", "Park", "Gym", "Cafe"
  ];

  // ✅ Defined mood factors from your provided list
  Map<String, List<String>> moodFactors = {
    "💼 Work & Productivity": [
      'Work-related', 'Work Environment', 'Time Management', 'Procrastination'
    ],
    "❤️ Personal Life & Relationships": [
      'Relationship', 'Family', 'Friends', 'Social Life', 'Social Media'
    ],
    "🧘 Health & Well-being": [
      'Sleep', 'Diet', 'Physical Health', 'Mental Health', 'Exercise'
    ],
    "📈 Financial & Career": [
      'Finance', 'Financial Stress', 'Education', 'Personal Goals'
    ],
    "🌍 Environment & External Factors": [
      'Weather', 'Seasonal Changes', 'Current Events', 'Technology/Device Use'
    ],
    "🎨 Lifestyle & Interests": [
      'Movie', 'Hobbies', 'Travel', 'Creativity', 'Spirituality'
    ],
    "🛌 Sleep & Recovery": ['Sleep Quality']
  };

  // ✅ Time slots for daily logs
  List<String> times = ["7 AM", "2 PM", "8 PM"];

  // ✅ Start and end dates
  DateTime startDate = DateTime(2023, 1, 3);
  DateTime endDate = DateTime.now(); // End date is today's date

  // ✅ Random notes (some can be empty, others human-like)
  List<String> randomNotes = [
    "Feeling great today!",
    "Had a productive day at work.",
    "Feeling a bit stressed.",
    "Enjoyed spending time with friends.",
    "Need to focus on my goals.",
    "Feeling relaxed after a workout.",
    "Weather was amazing today.",
    "Feeling a bit anxious about upcoming deadlines.",
    "Had a good day overall.",
    "Need to improve my sleep schedule.",
    "",
    "",
    "",
  ];

  List<MoodLog> moodLogs = [];

  // ✅ Loop through every day and generate mood logs
  while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
    for (String time in times) {
      // Randomly select mood
      String selectedMood = moods[Random().nextInt(moods.length)];

      // Randomly select intensity (between 1-5)
      int intensity = Random().nextInt(5) + 1;

      // Randomly select mood factors
      List<String> factorKeys = moodFactors.keys.toList();
      String selectedCategory = factorKeys[Random().nextInt(factorKeys.length)];
      List<String> selectedFactors = moodFactors[selectedCategory]!;

      // Randomly select a location
      String selectedLocation = locations[Random().nextInt(locations.length)];

      // Randomly select notes (some can be empty)
      String notes = randomNotes[Random().nextInt(randomNotes.length)];

      // Create the MoodLog object
      moodLogs.add(
        MoodLog(
          mood: selectedMood,
          intensityLevel: intensity,
          moodFactors: selectedFactors,
          location: selectedLocation,
          notes: notes, // Random notes (some can be empty)
          selectedTime: time,
          selectedDate: startDate,
        ),
      );
    }
    startDate = startDate.add(Duration(days: 1)); // Move to the next day
  }

  // ✅ Insert all generated data into the database
  for (var log in moodLogs) {
    await DatabaseHelper.instance.insertMoodLog(log);
  }

  print("✅ Inserted ${moodLogs.length} mood logs successfully!");
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const SignUpScreen(),
        'signin': (context) => const SignInScreen(),
        'dash': (context) => const DashboardScreen(),
      },
    );
  }
}






