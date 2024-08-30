# mind_journal

Flutter学習を目的に作成しました。
また、認知行動療法に関連した日記を作成したかったので、今回作成しました。
既存アプリでは入力項目が多く、気軽に投稿するという点がかけていると感じたので、作成に至りました。

<img width="437" alt=" 2024-08-31 6 12 02" src="https://github.com/user-attachments/assets/7b97c72b-233f-43af-b3cd-73407e5a865a">

# アプリの特徴

- 入力情報は少なく、気軽に記録できます
- タグで記録を管理することが可能です
- 日々の振り返りはカレンダー機能を用いて、チャット風のUIに実装しました
- 記録は、文字検索、お気に入り検索、並び替えなどにより振り返れます（タグ検索・感情検索の追加が必要）
- ダークモード対応
- フォント変更可能

# 使用ライブラリー

## メイン環境
provider: 状態管理用のライブラリ。
sqflite: ローカルのSQLiteデータベースとやり取りするためのライブラリ。
path_provider: デバイスのストレージパスへのアクセスを提供するライブラリ。
intl: 国際化およびローカライズのためのライブラリ。
shared_preferences: キーと値のペアをローカルストレージに保存するためのライブラリ。
table_calendar: カスタマイズ可能なカレンダーウィジェットのライブラリ。
cupertino_icons: アイコンセット。

## 開発環境
flutter_test: Flutterアプリケーションのテストを行うためのライブラリ。
flutter_lints: Flutterプロジェクト向けのコードリント（静的解析）ルールセット。
sqflite_common_ffi: sqfliteの共通インターフェースを提供し、ffiを使用してネイティブコードを呼び出すためのライブラリ。
