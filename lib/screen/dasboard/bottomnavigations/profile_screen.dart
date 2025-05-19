import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../database/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String appVersion = "1.0.0";
  String dbPath = "";
  String dbSize = "";
  int moodCount = 0;
  int todoCount = 0;
  String forecast = "";

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = "${dir.path}/moodlog.db";
    File dbFile = File(path);
    bool exists = await dbFile.exists();
    int sizeBytes = exists ? await dbFile.length() : 0;
    double sizeMB = sizeBytes / (1024 * 1024);

    final db = DatabaseHelper.instance;
    int mood = await db.getMoodCount();
    int todo = await db.getTodoCount();
    String latestForecast = await db.getForecast();

    setState(() {
      dbPath = path;
      dbSize = "${sizeMB.toStringAsFixed(2)} MB";
      moodCount = mood;
      todoCount = todo;
      forecast = latestForecast.isEmpty ? "None" : latestForecast;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final db = DatabaseHelper.instance;
    await db.deleteAllMoods();
    await db.deleteAllTodos();
    await db.saveForecast('');

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // deep dark background
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoTile("App Version", appVersion),
            _buildInfoTile("Mood Entries", "$moodCount"),
            _buildInfoTile("Todo Items", "$todoCount"),
            _buildInfoTile("Latest Forecast", forecast),
            _buildInfoTile("Database Size", dbSize),
            _buildInfoTile("Database Path", dbPath, isSmallText: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Text("Logout", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, {bool isSmallText = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.amber[100],
              fontSize: isSmallText ? 12 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
