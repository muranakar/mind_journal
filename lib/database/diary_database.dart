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
      'モヤモヤ',
      '悔しい',
      '感謝',
      '希望',
      '嬉しい',
      '仕事',
      '友達',
      '家族',
      '趣味'
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

  /// ホーム画面用のメソッド
  Future<List<String>> fetchAllTagsSortedByUsage() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
  SELECT DISTINCT tags.name
  FROM tags
  LEFT JOIN diary_tags ON tags.id = diary_tags.tag_id
  GROUP BY tags.name
  ORDER BY 
    CASE 
      WHEN COUNT(diary_tags.tag_id) = 0 THEN 1
      ELSE 0
    END,
    COUNT(diary_tags.tag_id) DESC,
    MIN(tags.id) ASC
  ''');

    return result.map((map) => map['name'] as String).toList();
  }

  /// タグ画面用のメソッド
  Future<List<Diary>> filterDiariesBySelectedTags(
      List<String> selectedTags) async {
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

// タグ検索画面用のメソッド
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

  /// タグ検索画面用のメソッド
  Future<List<Diary>> getDiariesByTags(List<String> tags) async {
    if (tags.isEmpty) {
      return [];
    }

    final placeholders = List.filled(tags.length, '?').join(',');
    final db = await instance.database;
    final results = await db.rawQuery('''
    SELECT DISTINCT d.*, GROUP_CONCAT(t.name) AS tag_names
    FROM diaries d
    JOIN diary_tags dt ON d.id = dt.diary_id
    JOIN tags t ON dt.tag_id = t.id
    WHERE t.name IN ($placeholders)
    GROUP BY d.id
  ''', tags);

    return results.map((map) => Diary.fromMap(map, [])).toList();
  }

  /// 一覧画面の検索メソッド
  Future<List<Diary>> searchDiaries(String keyword) async {
    final db = await instance.database;

    // diariesテーブルからキーワードを含む日記を検索
    // LIKE演算子で部分一致検索を実行
    final result = await db.query(
      'diaries',
      where: 'content LIKE ?',
      whereArgs: ['%$keyword%'], // %を使って部分一致検索
    );

    List<Diary> diaries = [];

    // 検索結果の各日記に関連するタグを取得
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

  /// 日記の更新
  Future<void> updateDiary(Diary diary) async {
    final db = await instance.database;

    await db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  /// 日記の削除
  Future<void> deleteDiary(int id) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 削除される日記に関連するタグのIDを取得
      List<Map<String, dynamic>> relatedTags = await txn.query('diary_tags',
          columns: ['tag_id'], where: 'diary_id = ?', whereArgs: [id]);

      // 日記エントリの削除
      await txn.delete('diaries', where: 'id = ?', whereArgs: [id]);

      // diary_tags テーブルから関連エントリを削除
      await txn.delete('diary_tags', where: 'diary_id = ?', whereArgs: [id]);

      // 関連していたタグを tags テーブルから削除
      for (var tag in relatedTags) {
        await txn.delete('tags', where: 'id = ?', whereArgs: [tag['tag_id']]);
      }
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
