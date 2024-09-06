import 'package:flutter_test/flutter_test.dart';
import 'package:mind_journal/database/diary_database.dart';
import 'package:mind_journal/model/diary.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:matcher/matcher.dart' as matcher;

void main() {

  late DiaryDatabase database;

  setUp(() async {
    // sqflite_common_ffi の初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // テスト用のデータベースを初期化
    database = DiaryDatabase.instance;
    
  });

  tearDown(() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'test_diaries.db');
    await deleteDatabase(path);
  });

  // test('CRUD処理を行えているか', () async {
  //   // Create
  //   final diary = Diary(
  //       title: 'Test Diary',
  //       content: 'This is a test diary.',
  //       isFavorite: false,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //       emotionImage: 'happy.png',
  //       tags: ['Flutter', 'Test']);

  //   await database.createDiary(diary);
  //   expect(diary.id, isNotNull);

    // Read
  //   List<Diary> diaries = await database.readAllDiaries();
  //   expect(diaries.length, 1);
  //   expect(diaries.first.title, 'Test Diary');

  //   // Update
  //   diary.title = 'Updated Diary';
  //   await database.updateDiary(diary);

  //   final updatedDiary = await database.readAllDiaries();
  //   expect(updatedDiary.first.title, 'Updated Diary');

  //   // Delete
  //   await database.deleteDiary(diary.id!);
  //   diaries = await database.readAllDiaries();
  //   expect(diaries.isEmpty, true);
  //       // Clean up
  //   await database.deleteDiary(diary.id!);
  // });

  // test('全てのタグを取得し、使用頻度順に並んでいるかどうか', () async {
  //   // Create a new diary with tags
  //   final diary = Diary(
  //       title: 'Tag Test Diary 1',
  //       content: 'This diary is for testing tags.',
  //       isFavorite: true,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //       emotionImage: 'neutral.png',
  //       tags: ['Flutter', 'Dart', 'Database']);

  //   final diary2 = Diary(
  //       title: 'Tag Test Diary 2',
  //       content: 'This diary is for testing tags.',
  //       isFavorite: true,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //       emotionImage: 'neutral.png',
  //       tags: ['Flutter', 'Database']);

  //   final diary3 = Diary(
  //       title: 'Tag Test Diary 3',
  //       content: 'This diary is for testing tags.',
  //       isFavorite: true,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //       emotionImage: 'neutral.png',
  //       tags: ['Flutter']);

  //   await database.createDiary(diary);
  //   await database.createDiary(diary2);
  //   await database.createDiary(diary3);

  //   // Get all tags sorted by usage
  //   final tags = await database.fetchAllTagsSortedByUsage();

  //   // Check that tags are in the correct order
  //   expect(tags,matcher.equals(['Flutter', 'Database', 'Dart']));

  //   // Clean up
  //   await database.deleteDiary(diary.id!);
  //   await database.deleteDiary(diary2.id!);
  //   await database.deleteDiary(diary3.id!);
  // });
}
