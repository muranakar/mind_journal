import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mind_journal/model/diary.dart';

class DiaryDatabase {
  static final DiaryDatabase instance = DiaryDatabase._init();

  static Database? _database;

  DiaryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('diaries.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createDB(db, version);
        await _insertInitialTags(db); // 初回起動時にタグを挿入
      },
    );

    return database;
  }

  Future<Database> get testDatabase async {
    if (_database != null) return _database!;

    // 一時的なテストデータベースを作成
    _database = await _initDB('test_diaries.db');
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE diaries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      content TEXT,
      is_favorite INTEGER,
      created_at TEXT,
      updated_at TEXT,
      emotion_image TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE diary_tags (
      diary_id INTEGER,
      tag_id INTEGER,
      FOREIGN KEY(diary_id) REFERENCES diaries(id),
      FOREIGN KEY(tag_id) REFERENCES tags(id)
    )
    ''');
  }

  Future _insertInitialTags(Database db) async {
    const List<String> initialTags = [
      '不安',
      '喜び',
      '怒り',
      '悲しみ',
      'イライラ',
      '安心',
      '安堵',
      '満足',
      '孤独感',
      '恐怖',
      '焦り',
      '悔しさ',
      '罪悪感',
      '感謝',
      '恥',
      '無力感',
      '嫉妬',
      '驚き',
      '困惑',
      '希望'
    ];

    // タグが既に挿入されているか確認
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tags'));
    if (count == 0) {
      // 初回起動時のみタグを挿入
      for (String tag in initialTags) {
        await db.insert('tags', {'name': tag});
      }
    }
  }

  Future<List<String>> getTagsForDiary(int diaryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_tags',
      where: 'diary_id = ?',
      whereArgs: [diaryId],
    );

    // タグIDを取得し、タグ名を検索する
    List<String> tags = [];
    for (var map in maps) {
      final tagMap = await db.query(
        'tags',
        where: 'id = ?',
        whereArgs: [map['tag_id']],
      );
      if (tagMap.isNotEmpty) {
        tags.add(tagMap.first['name'] as String);
      }
    }

    return tags;
  }

  Future<void> createDiary(Diary diary) async {
    final db = await instance.database;

    final id = await db.insert('diaries', diary.toMap());
    diary.id = id;
    // タグの関連付け
    for (String tag in diary.tags) {
      final tagId = await db.insert('tags', {'name': tag});
      await db.insert('diary_tags', {'diary_id': diary.id, 'tag_id': tagId});
    }
  }

  Future<List<Diary>> readAllDiaries() async {
    final db = await instance.database;

    // diaries テーブルのすべてのデータを取得
    final result = await db.query('diaries');

    // 日記リストを作成
    List<Diary> diaries = [];

    // 各日記に関連するタグを取得して Diary オブジェクトを作成
    for (var map in result) {
      // diary_id をもとに関連するタグを取得
      final List<Map<String, dynamic>> tagMaps = await db.query(
        'diary_tags',
        where: 'diary_id = ?',
        whereArgs: [map['id']],
      );

      // タグ名のリストを作成
      List<String> tags = [];
      for (var tagMap in tagMaps) {
        final List<Map<String, dynamic>> tagNameMap = await db.query(
          'tags',
          where: 'id = ?',
          whereArgs: [tagMap['tag_id']],
        );
        if (tagNameMap.isNotEmpty) {
          tags.add(tagNameMap.first['name']);
        }
      }

      // Diary オブジェクトを作成してリストに追加
      diaries.add(Diary.fromMap(map, tags));
    }

    return diaries;
  }

  Future<Map<String, int>> getTagCounts() async {
    final db = await instance.database;

    // タグごとの関連日記数を取得するクエリ
    final result = await db.rawQuery('''
    SELECT tags.name, COUNT(diary_tags.diary_id) as count
    FROM tags
    LEFT JOIN diary_tags ON tags.id = diary_tags.tag_id
    GROUP BY tags.name
  ''');

    // 結果をMapに変換
    Map<String, int> tagCounts = {};
    for (var row in result) {
      tagCounts[row['name'] as String] = row['count'] as int;
    }

    return tagCounts;
  }

  Future<List<Diary>> filterDiariesBySelectedTags(List<String> selectedTags) async {
  final db = await DiaryDatabase.instance.database;

  if (selectedTags.isEmpty) {
    // タグが選択されていない場合は全ての日記を取得
    final result = await db.query('diaries');
    return result.map((map) => Diary.fromMap(map, [])).toList();
  }

  // タグが選択されている場合、選択されたタグに一致する日記を取得
  final tagPlaceholders = List.filled(selectedTags.length, '?').join(', ');
  final result = await db.rawQuery('''
    SELECT DISTINCT diaries.*
    FROM diaries
    JOIN diary_tags ON diaries.id = diary_tags.diary_id
    JOIN tags ON diary_tags.tag_id = tags.id
    WHERE tags.name IN ($tagPlaceholders)
  ''', selectedTags);

  return result.map((map) => Diary.fromMap(map, selectedTags)).toList();
}


  Future<void> updateDiary(Diary diary) async {
    final db = await instance.database;

    await db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  Future<void> deleteDiary(int id) async {
    final db = await instance.database;

    await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> fetchAllTagsSortedByUsage() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT tags.name, COUNT(diary_tags.tag_id) as tag_count
    FROM tags
    LEFT JOIN diary_tags ON tags.id = diary_tags.tag_id
    GROUP BY tags.name
    ORDER BY tag_count DESC
  ''');

    return result.map((map) => map['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAllMapTagsSortedByUsage() async {
  final db = await instance.database;
  final result = await db.rawQuery('''
    SELECT tags.name, COUNT(diary_tags.diary_id) as count
    FROM tags
    LEFT JOIN diary_tags ON tags.id = diary_tags.tag_id
    GROUP BY tags.name
    ORDER BY count DESC
  ''');

  // タグ名と件数を保持したMapを返す
  return result.map((row) {
    return {
      'name': row['name'] as String,
      'count': row['count'] as int,
    };
  }).toList();
}


  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
