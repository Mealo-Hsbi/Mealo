class Achievement {
  final String id;
  final String key;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;

  Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      unlocked: json['unlocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
    };
  }

  @override
  String toString() {
    return 'Achievement(id: $id, key: $key, title: $title, unlocked: $unlocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 