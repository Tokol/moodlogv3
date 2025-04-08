import 'package:flutter/material.dart';

class MoodForm extends StatefulWidget {
  const MoodForm({super.key});

  @override
  State<MoodForm> createState() => _MoodFormState();
}

class _MoodFormState extends State<MoodForm> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'mood': 'Happy'},
    {'emoji': '😃', 'mood': 'Excited'},
    {'emoji': '😄', 'mood': 'Grinning'},
    {'emoji': '😅', 'mood': 'Relieved'},
    {'emoji': '😎', 'mood': 'Confident'},
    {'emoji': '😍', 'mood': 'Love'},
    {'emoji': '🥰', 'mood': 'Affectionate'},
    {'emoji': '🤩', 'mood': 'Amazed'},
    {'emoji': '😋', 'mood': 'Satisfied'},
    {'emoji': '😌', 'mood': 'Relaxed'},
    {'emoji': '😔', 'mood': 'Sad'},
    {'emoji': '😞', 'mood': 'Disappointed'},
    {'emoji': '😢', 'mood': 'Crying'},
    {'emoji': '😭', 'mood': 'Devastated'},
    {'emoji': '😩', 'mood': 'Exhausted'},
    {'emoji': '😖', 'mood': 'Distressed'},
    {'emoji': '😕', 'mood': 'Confused'},
    {'emoji': '🤔', 'mood': 'Thinking'},
    {'emoji': '😟', 'mood': 'Worried'},
    {'emoji': '😠', 'mood': 'Angry'},
    {'emoji': '🤬', 'mood': 'Furious'},
    {'emoji': '😤', 'mood': 'Frustrated'},
    {'emoji': '😡', 'mood': 'Mad'},
    {'emoji': '😷', 'mood': 'Sick'},
    {'emoji': '🤢', 'mood': 'Nauseous'},
    {'emoji': '🤮', 'mood': 'Vomiting'},
    {'emoji': '🥺', 'mood': 'Pleading'},
    {'emoji': '😴', 'mood': 'Tired'},
    {'emoji': '😵', 'mood': 'Dizzy'},
    {'emoji': '🤯', 'mood': 'Mind-blown'},
    {'emoji': '😜', 'mood': 'Playful'},
    {'emoji': '😝', 'mood': 'Silly'},
    {'emoji': '🤗', 'mood': 'Hug'},
    {'emoji': '🙃', 'mood': 'Upside down'},
    {'emoji': '😇', 'mood': 'Innocent'},
    {'emoji': '🤩', 'mood': 'Excited'},
    {'emoji': '😎', 'mood': 'Cool'},
    {'emoji': '🤤', 'mood': 'Desiring'},
    {'emoji': '😺', 'mood': 'Happy Cat'},
    {'emoji': '😸', 'mood': 'Grinning Cat'},
    {'emoji': '🙄', 'mood': 'Eye Roll'},
    {'emoji': '😳', 'mood': 'Shocked'},
    {'emoji': '🥳', 'mood': 'Celebration'},
    {'emoji': '🤠', 'mood': 'Adventurous'},
    {'emoji': '🤡', 'mood': 'Creeped out'},
    {'emoji': '🥶', 'mood': 'Freezing'},
    {'emoji': '🤑', 'mood': 'Greedy'},
    {'emoji': '😏', 'mood': 'Flirty'},
    {'emoji': '🤐', 'mood': 'Silent'},
    {'emoji': '😬', 'mood': 'Awkward'},
  ];

  bool isEmojiSelected = false;
  String selectedEmoji = '';
  String selectedMood = '';
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0E8D5),
      appBar: AppBar(
        title: Text('How Do You Feel Today?'),
        backgroundColor: Color(0xFF6A1B9A),
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Grid View with Improved Design
          Visibility(
            visible: !isEmojiSelected,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: moods.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isEmojiSelected = true;
                      selectedEmoji = moods[index]['emoji'];
                      selectedMood = moods[index]['mood'];
                    });
                  },
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            moods[index]['emoji'],
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            moods[index]['mood'],
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Enlarged Emoji and Mood View with Animation
          Visibility(
            visible: isEmojiSelected,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.clear, size: 40, color: Color(0xFF6A1B9A)),
                    onPressed: () {
                      setState(() {
                        isEmojiSelected = false;
                      });
                    },
                  ),
                  ScaleTransition(
                    scale: Tween(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _scaleController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: Tween(begin: 0.0, end: 1.0).animate(_scaleController),
                      child: Text(
                        selectedEmoji,
                        style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    selectedMood,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
