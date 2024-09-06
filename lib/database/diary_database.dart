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
        await _insertInitialTags(db);  // 初回起動時にタグを挿入
      },
    );

    return database;
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
      '不安', '喜び', '怒り', '悲しみ', 'イライラ', '安心', '安堵', 
      '満足', '孤独感', '恐怖', '焦り', '悔しさ', '罪悪感', '感謝', 
      '恥', '無力感', '嫉妬', '驚き', '困惑', '希望'
    ];

    // タグが既に挿入されているか確認
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tags'));
    if (count == 0) {
      // 初回起動時のみタグを挿入
      for (String tag in initialTags) {
        await db.insert('tags', {'name': tag});
      }
    }
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

    final result = await db.query('diaries');
    return result.map((map) => Diary.fromMap(map)).toList();
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
