import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:mind_journal/model/diary_notifier.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// データベースプロバイダー
final databaseProvider = Provider<Database?>((ref) => null);

// DiaryDatabaseプロバイダー
final diaryDatabaseProvider = Provider<DiaryDatabase>((ref) {
  return DiaryDatabase(ref);
});

class DiaryDatabase {
  final Ref _ref;
  Database? _database;

  DiaryDatabase(this._ref);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diaries.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createDB(db, version);
        await _insertInitialTags(db);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
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
      name TEXT UNIQUE
    )
    ''');

    await db.execute('''
    CREATE TABLE diary_tags (
      diary_id INTEGER,
      tag_id INTEGER,
      FOREIGN KEY(diary_id) REFERENCES diaries(id),
      FOREIGN KEY(tag_id) REFERENCES tags(id),
      PRIMARY KEY(diary_id, tag_id)
    )
    ''');
  }

  Future<void> _insertInitialTags(Database db) async {
    const List<String> initialTags = [
      '不安', '喜び', '怒り', '悲しみ', 'イライラ', 'モヤモヤ',
      '悔しい', '感謝', '希望', '嬉しい', '仕事', '友達', '家族', '趣味'
    ];

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tags')
    );
    
    if (count == 0) {
      for (String tag in initialTags) {
        await db.insert('tags', {'name': tag});
      }
    }
  }

  // 日記の作成
  Future<int> createDiary(Diary diary) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      // 日記を保存
      final id = await txn.insert('diaries', diary.toMap());
      
      // タグを保存
      for (String tagName in diary.tags) {
        // タグが存在しない場合は新規作成
        final List<Map<String, dynamic>> existingTags = await txn.query(
          'tags',
          where: 'name = ?',
          whereArgs: [tagName],
        );

        int tagId;
        if (existingTags.isEmpty) {
          tagId = await txn.insert('tags', {'name': tagName});
        } else {
          tagId = existingTags.first['id'] as int;
        }

        // 日記とタグを関連付け
        await txn.insert('diary_tags', {
          'diary_id': id,
          'tag_id': tagId,
        });
      }
      
      return id;
    });
  }

  // 全ての日記を取得
  Future<List<Diary>> readAllDiaries() async {
    final db = await database;
    final diaries = await db.query('diaries', orderBy: 'created_at DESC');
    
    return Future.wait(diaries.map((diary) async {
      final tags = await getTagsForDiary(diary['id'] as int);
      return Diary.fromMap(diary, tags);
    }));
  }

  // 特定の日記のタグを取得
  Future<List<String>> getTagsForDiary(int diaryId) async {
    final db = await database;
    
    final result = await db.rawQuery('''
      SELECT tags.name
      FROM tags
      JOIN diary_tags ON tags.id = diary_tags.tag_id
      WHERE diary_tags.diary_id = ?
    ''', [diaryId]);

    return result.map((row) => row['name'] as String).toList();
  }

  // 日記の更新
  Future<void> updateDiary(Diary diary) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // 日記を更新
      await txn.update(
        'diaries',
        diary.toMap(),
        where: 'id = ?',
        whereArgs: [diary.id],
      );

      // 既存のタグ関連を削除
      await txn.delete(
        'diary_tags',
        where: 'diary_id = ?',
        whereArgs: [diary.id],
      );

      // 新しいタグを関連付け
      for (String tagName in diary.tags) {
        final List<Map<String, dynamic>> existingTags = await txn.query(
          'tags',
          where: 'name = ?',
          whereArgs: [tagName],
        );

        int tagId;
        if (existingTags.isEmpty) {
          tagId = await txn.insert('tags', {'name': tagName});
        } else {
          tagId = existingTags.first['id'] as int;
        }

        await txn.insert('diary_tags', {
          'diary_id': diary.id,
          'tag_id': tagId,
        });
      }
    });
  }

  // 日記の削除
  Future<void> deleteDiary(int id) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // 日記とタグの関連を削除
      await txn.delete(
        'diary_tags',
        where: 'diary_id = ?',
        whereArgs: [id],
      );

      // 日記を削除
      await txn.delete(
        'diaries',
        where: 'id = ?',
        whereArgs: [id],
      );

      // 使用されていないタグを削除
      await txn.rawDelete('''
        DELETE FROM tags
        WHERE id NOT IN (
          SELECT DISTINCT tag_id FROM diary_tags
        )
      ''');
    });
  }

  // タグを使用頻度順に取得
  Future<List<String>> fetchAllTagsSortedByUsage() async {
    final db = await database;
    
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
        tags.name ASC
    ''');

    return result.map((row) => row['name'] as String).toList();
  }

  // タグの使用回数を含めて取得
  Future<List<Map<String, dynamic>>> fetchTagsWithUsageCount() async {
    final db = await database;
    
    final result = await db.rawQuery('''
      SELECT 
        tags.name,
        COUNT(diary_tags.diary_id) as count
      FROM tags
      LEFT JOIN diary_tags ON tags.id = diary_tags.tag_id
      GROUP BY tags.name
      ORDER BY count DESC, tags.name ASC
    ''');

    return result.map((row) => {
      'name': row['name'] as String,
      'count': row['count'] as int,
    }).toList();
  }

  // キーワードで日記を検索
  Future<List<Diary>> searchDiaries(String keyword) async {
    final db = await database;
    
    final diaries = await db.query(
      'diaries',
      where: 'content LIKE ? OR title LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'created_at DESC'
    );

    return Future.wait(diaries.map((diary) async {
      final tags = await getTagsForDiary(diary['id'] as int);
      return Diary.fromMap(diary, tags);
    }));
  }

  // タグで日記をフィルター
  Future<List<Diary>> getDiariesByTags(List<String> tagNames) async {
    if (tagNames.isEmpty) return [];
    
    final db = await database;
    final placeholders = List.filled(tagNames.length, '?').join(',');
    
    final diaries = await db.rawQuery('''
      SELECT DISTINCT d.*
      FROM diaries d
      JOIN diary_tags dt ON d.id = dt.diary_id
      JOIN tags t ON dt.tag_id = t.id
      WHERE t.name IN ($placeholders)
      ORDER BY d.created_at DESC
    ''', tagNames);

    return Future.wait(diaries.map((diary) async {
      final tags = await getTagsForDiary(diary['id'] as int);
      return Diary.fromMap(diary, tags);
    }));
  }

  Future<List<Diary>> filterDiariesBySelectedTags(List<String> selectedTags) async {
    final db = await database;
print(1000);
    if (selectedTags.isEmpty) {
      // タグが選択されていない場合は全ての日記を取得
      final result = await db.query('diaries');
      return Future.wait(result.map((map) async {
        final tags = await getTagsForDiary(map['id'] as int);
        return Diary.fromMap(map, tags);
      }));
    }
    print(1);
    // タグが選択されている場合、選択されたタグに一致する日記を取得
    final tagPlaceholders = List.filled(selectedTags.length, '?').join(', ');
    final result = await db.rawQuery('''
      SELECT DISTINCT diaries.*
      FROM diaries
      JOIN diary_tags ON diaries.id = diary_tags.diary_id
      JOIN tags ON diary_tags.tag_id = tags.id
      WHERE tags.name IN ($tagPlaceholders)
      GROUP BY diaries.id
      HAVING COUNT(DISTINCT tags.name) = ?
    ''', [...selectedTags, selectedTags.length]);
print(2);
    // 各日記のタグを取得して Diary オブジェクトを作成
    return Future.wait(result.map((map) async {
      final tags = await getTagsForDiary(map['id'] as int);
      return Diary.fromMap(map, tags);
    }));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diaries.db');
    await databaseFactory.deleteDatabase(path);
  }
}

// 日記一覧を提供するプロバイダー
final diariesProvider = StateNotifierProvider<DiaryNotifier, List<Diary>>((ref) {
  final database = ref.watch(diaryDatabaseProvider);
  return DiaryNotifier(database);
});

// タグ一覧を提供するプロバイダー
final tagsProvider = FutureProvider<List<String>>((ref) async {
  final database = ref.watch(diaryDatabaseProvider);
  return database.fetchAllTagsSortedByUsage();
});

// タグの使用状況を提供するプロバイダー
final tagUsageProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final database = ref.watch(diaryDatabaseProvider);
  return database.fetchTagsWithUsageCount();
});