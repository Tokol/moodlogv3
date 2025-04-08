import 'package:intl/intl.dart';

class MoodLog {
  final int? id; // ✅ Add ID for primary key
  final String mood;
  final int intensityLevel;
  final List<String> moodFactors;
  final String location;
  final String notes;
  final String selectedTime;
  final DateTime selectedDate; // Always today's date

  MoodLog({
    this.id, // ✅ Optional ID (for database auto-increment)
    required this.mood,
    required this.intensityLevel,
    required this.moodFactors,
    required this.location,
    required this.notes,
    required this.selectedTime,
    required this.selectedDate,
  });

  // ✅ Convert Model to Map for SQLite Insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id, // ✅ Include ID for updates
      'mood': mood,
      'intensityLevel': intensityLevel,
      'moodFactors': moodFactors.join(','), // ✅ Convert List to String for storage
      'location': location,
      'notes': notes,
      'selectedTime': selectedTime,
      'selectedDate': DateFormat('yyyy-MM-dd').format(selectedDate), // ✅ Convert DateTime to String
    };
  }

  // ✅ Convert Map from SQLite to Model
  factory MoodLog.fromMap(Map<String, dynamic> map) {
    return MoodLog(
      id: map['id'],
      mood: map['mood'],
      intensityLevel: map['intensityLevel'],
      moodFactors: (map['moodFactors'] as String).split(','), // ✅ Convert CSV String back to List
      location: map['location'],
      notes: map['notes'],
      selectedTime: map['selectedTime'],
      selectedDate: DateTime.parse(map['selectedDate']), // ✅ Convert String to DateTime
    );
  }

  @override
  String toString() {
    return "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}, Time: $selectedTime, Mood: $mood, Intensity: $intensityLevel, Factors: $moodFactors, Location: $location, Notes: ${notes.isNotEmpty ? notes : "No Notes"}";
  }
}
