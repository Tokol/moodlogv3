import 'package:flutter/material.dart';

// Expandable Objectives Section
class ExpandableCard extends StatefulWidget {
  final String title;
  final List<String> items;

  const ExpandableCard({required this.title, required this.items, Key? key}) : super(key: key);

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        children: widget.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
