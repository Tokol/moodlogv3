class TodoItem {
  String title;
  String description;
  String? url;
  String? thumbnailUrl;
  String duration;
  String category;
  String date;
  List<String> tags;
  bool isCompleted;

  TodoItem({
    required this.title,
    required this.description,
    this.url,
    this.thumbnailUrl,
    required this.duration,
    required this.category,
    required this.date,
    this.tags = const [],
    this.isCompleted = false,
  });

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'],
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'] ?? '',
      category: map['category'] ?? '',
      date: map['date'] ?? '',
      tags: (map['tags'] as String?)?.split(',') ?? [],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'category': category,
      'date': date,
      'tags': tags.join(','),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}