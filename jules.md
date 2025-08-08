# Ruby 環境構築手順

このリポジトリの Ruby スクリプトを実行するための環境を構築します。

## 概要

環境構築のプロセスは、`script/setup_environment.sh` スクリプトによって大部分が自動化されています。

また、このリポジトリは使用する Ruby のバージョンを `.ruby-version` ファイルで指定しており、`rbenv` はこのファイルを自動的に読み込んで適切なバージョンをインストールします。

## セットアップ手順

以下のコマンドを一度だけ実行してください。

```bash
bash script/setup_environment.sh
```

スクリプトは以下の処理を自動的に行います。

*   `rbenv` と `ruby-build` のインストール
*   シェルの設定 (`.bashrc` の更新)
*   Ruby のビルドに必要な依存パッケージのインストール
*   `.ruby-version` ファイルに基づいた Ruby のインストール
*   `bundler` およびスクリプトに必要なその他の gem のインストール

### 実行後

スクリプトの実行が完了したら、**シェルを再起動する**か、以下のコマンドを実行してシェルの設定を再読み込みしてください。

```bash
source ~/.bashrc
```

これで、Ruby の実行環境が整いました。

## 設定 (Configuration)

スクリプトを実行する前に、APIキーなどの秘匿情報を含んだ `lib/hitoku.rb` ファイルを手動で作成する必要があります。このファイルはバージョン管理下に置かれるべきではありません。

`lib` ディレクトリが存在しない場合は作成してください。

```bash
mkdir -p lib
```

次に、`lib/hitoku.rb` を以下の内容で作成し、`'YOUR_..._KEY'` の部分を実際のキーに置き換えてください。

```ruby
# lib/hitoku.rb
module Hitoku
  def self.switchbot_api_token
    'YOUR_SWITCHBOT_API_TOKEN'
  end

  def self.switchbot_api_secret
    'YOUR_SWITCHBOT_API_SECRET'
  end

  def self.ambient_write_key
    'YOUR_AMBIENT_WRITE_KEY'
  end

  def self.ambient_read_key
    'YOUR_AMBIENT_READ_KEY'
  end
end
```

## スクリプトの実行方法

`app/kaiteki.rb` のように、`lib` ディレクトリにあるローカルライブラリに依存するスクリプトを実行するには、`-Ilib` オプションを使って Ruby にライブラリの場所を伝える必要があります。

```bash
ruby -Ilib script/kaiteki.rb
```
