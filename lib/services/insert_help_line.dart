import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> insertHelplineData() async {
  final firestore = FirebaseFirestore.instance;

  // Your data structure
  final helplineData = [
    {
      "type": "Anti-Suicide Support",
      "organizations": [
        {
          "name": "Lifeline Nepal",
          "description": "24/7 emotional support for individuals in crisis and suicidal thoughts.",
          "phone": "+977-1-5551234"
        },
        {
          "name": "Hope Helpline",
          "description": "Free and confidential suicide prevention helpline.",
          "phone": "+977-9801234567"
        }
      ]
    },
    {
      "type": "Depression & Anxiety Support",
      "organizations": [
        {
          "name": "Peace of Mind Center",
          "description": "Therapy and group sessions for people battling depression and anxiety.",
          "phone": "+977-1-4422333"
        },
        {
          "name": "Mindful Nepal",
          "description": "Mental wellness programs focusing on mindfulness and stress relief.",
          "phone": "+977-9807654321"
        }
      ]
    },
    {
      "type": "Online Counseling",
      "organizations": [
        {
          "name": "eCounsel Nepal",
          "description": "Licensed therapists offering online video sessions.",
          "phone": "+977-9801010101"
        },
        {
          "name": "TheraConnect",
          "description": "Connect with counselors anonymously via chat and call.",
          "phone": "+977-9802020202"
        }
      ]
    }
  ];

  try {
    // Delete existing collection if needed (optional)
    // await _deleteCollection(firestore.collection('helplines'));

    // Batch write for better performance
    final batch = firestore.batch();

    for (final category in helplineData) {
      final docRef = firestore.collection('helplines').doc(); // Auto-generated ID
      batch.set(docRef, category);
    }

    await batch.commit();
    print('Successfully inserted ${helplineData.length} helpline categories');
  } catch (e) {
    print('Error inserting helpline data: $e');
  }
}

// Optional helper to clear existing data
Future<void> _deleteCollection(CollectionReference collection) async {
  final snapshot = await collection.get();
  final batch = collection.firestore.batch();

  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }

  await batch.commit();
}