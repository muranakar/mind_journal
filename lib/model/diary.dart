class Diary {
  int? id;
  String title;
  String content;
  bool isFavorite;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;
  String emotionImage;

  Diary({
    this.id,
    required this.title,
    required this.content,
    this.isFavorite = false,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.emotionImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toUtc().toIso8601String(), // DateTimeを文字列に変換
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'emotion_image': emotionImage,
    };
  }

  static Diary fromMap(Map<String, dynamic> map,List<String> tags) {
    return Diary(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isFavorite: map['is_favorite'] == 1,
      tags: tags.toList(),
      createdAt: DateTime.parse(map['created_at']).toLocal(), // 文字列をDateTimeに変換
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
      emotionImage: map['emotion_image'],
    );
  }
}
