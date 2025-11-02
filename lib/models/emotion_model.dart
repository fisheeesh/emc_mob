class EmotionCategory {
  final String title;
  final List<Emotion> emotions;

  EmotionCategory({
    required this.title,
    required this.emotions,
  });

  factory EmotionCategory.fromJson(Map<String, dynamic> json) {
    return EmotionCategory(
      title: json['title'],
      emotions: (json['emotions'] as List)
          .map((e) => Emotion.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'emotions': emotions.map((e) => e.toJson()).toList(),
    };
  }
}

class Emotion {
  final String icon;
  final String label;

  Emotion({
    required this.icon,
    required this.label,
  });

  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      icon: json['icon'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'label': label,
    };
  }
}