import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary.freezed.dart';

@freezed
class Diary with _$Diary {
  const factory Diary({
    int? id,
    required String title,
    required String content,
    @Default(false) bool isFavorite,
    required List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String emotionImage,
  }) = _Diary;

  // カスタムコンストラクタを追加
  const Diary._();

  // SQLiteのMapからDiaryオブジェクトを生成するファクトリメソッド
  factory Diary.fromMap(Map<String, dynamic> map, List<String> tags) {
    return Diary(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
      tags: tags,
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
      emotionImage: map['emotion_image'] as String,
    );
  }

  // DairyオブジェクトをSQLite用のMapに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'emotion_image': emotionImage,
    };
  }
}