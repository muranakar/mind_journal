# mind_journal

Flutter学習を目的に作成しました。
また、認知行動療法に関連した日記を作成したかったので、今回作成しました。
既存アプリでは入力項目が多いため、気軽に投稿・振り返りができる点を強みとして作成に至りました。

# アプリの特徴

- 入力情報は少なく、気軽に記録できます
- タグで記録を管理することが可能です
- 日々の振り返りはカレンダー機能を用いて、チャット風のUIに実装しました
- 記録は、文字検索、お気に入り検索、並び替えなどにより振り返れます（タグ検索・感情検索の追加が必要）
- ダークモード対応
- フォント変更可能

# スクリーンショット

<img width="170" alt="2024-08-31 6 12 02" src="https://github.com/user-attachments/assets/7b97c72b-233f-43af-b3cd-73407e5a865a">
<img width="170" alt="2024-08-31 6 13 24" src="https://github.com/user-attachments/assets/8afd97ef-5de6-455a-bb7c-bb4cbb97351f">
<img width="170" alt="image" src="https://github.com/user-attachments/assets/3d8d9387-bf7f-48cc-8e8b-e2acbf43831f">
<img width="170" alt="image" src="https://github.com/user-attachments/assets/00ccd1cf-b50d-40c2-a198-628f73671856">
<img width="170" alt="image" src="https://github.com/user-attachments/assets/682785d3-afa1-4d27-a27e-fa5455203280"><br>

<img width="170" alt="image" src="https://github.com/user-attachments/assets/081eccbe-fca7-47f5-adbd-d096cd8bba64">
<img width="170" alt="image" src="https://github.com/user-attachments/assets/95693a51-324d-4f89-8fd8-c327fa34c8d5">
<img width="170" alt="image" src="https://github.com/user-attachments/assets/e0cf2892-3d35-4851-b7c9-21683e5cd73c">
<img width="170" alt="image" src="https://github.com/user-attachments/assets/b7da22f7-f192-486b-b18f-0250f7531857">
<img width="170" alt="image" src="https://github.com/user-attachments/assets/2b0f01be-ee75-485b-88dd-ca409c567b1a">


# 使用ライブラリー

### メイン環境
- provider: 状態管理用のライブラリ。
- sqflite: ローカルのSQLiteデータベースとやり取りするためのライブラリ。
- path_provider: デバイスのストレージパスへのアクセスを提供するライブラリ。
- shared_preferences: キーと値のペアをローカルストレージに保存するためのライブラリ。
- table_calendar: カスタマイズ可能なカレンダーウィジェットのライブラリ。
今後使用予定）  
- intl: 国際化およびローカライズのためのライブラリ。
- cupertino_icons: アイコンセット。

### 開発環境
- flutter_test: Flutterアプリケーションのテストを行うためのライブラリ。
- - flutter_lints: Flutterプロジェクト向けのコードリント（静的解析）ルールセット。
- sqflite_common_ffi: sqfliteの共通インターフェースを提供し、ffiを使用してネイティブコードを呼び出すためのライブラリ。

# 学んだこと

### Flutterの基本
- Dartの文法
- ディレクトリー構成
- ListView,Row,Column　などの基本的なWidgetの役割


### Providerを用いた実装（lib/model/deviceInfo.dart）
- フォント、ダークモードなどの状態管理のため


### SQLiteを用いた実装（lib/database/diary_database.dart）
- DBとDartの型に合わせたデータ変換
- sqfliteライブラリーの使用法


### テスト実装（test/diary_database_test.dart　）
- sqfliteを用いてテスト実装
- 簡単なCRUD処理が行えているかのチェック
- 日記の入力画面において、タグの表示順を使用頻度順に並べているので、その部分のユニットテスト


# 次回以降の課題

- Flutterアプリで用いられているアーキテクチャの学習
- Riverpodを用いた状態管理の学習
- APIを用いた通信の学習

このあたりが直近の課題です。
