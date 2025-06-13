# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

「karma」は日々のミッション管理と環境データ収集を行うRubyプロジェクトです。以下の外部サービスと連携しています：

- **Todoist** - `todoist_cms` gemを使用したタスク管理
- **SwitchBot** - IoTデバイスからのデータ収集
- **Hackerel** - メトリクス投稿（カスタムサービス）
- **Hitoku** - 設定管理

## アーキテクチャ

シンプルなRubyライブラリ構造に従っています：

- `lib/hackerel/` - Hackerelサービスへのメトリクス投稿用コアライブラリ
- `script/` - 日常業務用の実行可能スクリプト
- `Rakefile` - 共通操作用のタスク定義

主要な統合ポイント：
- `Hitoku` gemが一元的な設定管理（APIトークン、シークレット）を提供
- スクリプトは `lib/hackerel` クライアントを使用して環境データを投稿
- 日々のミッションはランダムに生成されTodoistに投稿される

## 共通コマンド

### セットアップ
```bash
bundle install
```

### 日々のミッション選択を実行
```bash
rake daily_missions:choice
```

### スクリプトを直接実行
```bash
ruby script/choice_daily_missions.rb
ruby script/co2_to_hackerel.rb
```

## 設定

プロジェクトは暗号化された認証情報と `hitoku.key` ファイルを使用して設定されています。APIトークンとシークレットは `Hitoku` モジュール経由でアクセスします：

- `Hitoku.todoist_api_token` - Todoist APIアクセス
- `Hitoku.switchbot_api_token` - SwitchBot APIトークン
- `Hitoku.switchbot_api_secret` - SwitchBot APIシークレット

## スクリプト機能

- `choice_daily_missions.rb` - 事前定義されたリストから3つのミッションをランダムに選択してTodoistタスクとして作成
- `co2_to_hackerel.rb` - SwitchBotセンサーからCO2濃度を取得してHackerelにデータを投稿