import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodlog/screen/dasboard/bottomnavigations/mood_home_screen.dart';

import 'bottomnavigations/analytics_screen.dart';
import 'mood_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MoodHomeScreen(),
    AnalyticsScreen(),
    PostScreen(),
    HelpLineScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Colors.yellow,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.amber.shade700), // ✅ Yellow background
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.amber.shade700, // ✅ Yellow background
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black, // ✅ Black for selected item (strong contrast)
          unselectedItemColor: Colors.black54, // ✅ Dark gray for unselected (readable but subtle)
          onTap:  (index) {
            if (index == 2) { // ✅ If "Post" is clicked, check time and log status
              _onPostTap(context);
            } else {
              _onItemTapped(index); // Normal navigation for other tabs
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Post"),
            BottomNavigationBarItem(icon: Icon(Icons.phone_in_talk), label: "Help Line"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),

    );
  }


  void _onPostTap(BuildContext context) async {
    // Get the current time
    DateTime now = DateTime.now();

    // Format the current time to "h a" format (e.g., "7 AM" or "2 PM")
    String selectedTime = DateFormat('h a').format(now);

    // Navigate to MoodSelectionScreen with the current time
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodSelectionScreen(selectedTime: selectedTime),
      ),
    );

    // Refresh the UI if needed
    if (result == true) {
      (context as Element).markNeedsBuild();
    }
  }






}


// Placeholder Screens


class PostScreen extends StatelessWidget {
  const PostScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Post Screen")));
  }
}

class HelpLineScreen extends StatelessWidget {
  const HelpLineScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Help Line Screen")));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Profile Screen")));
  }
}
