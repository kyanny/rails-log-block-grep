# rails-log-block-grep.rb

Ruby on Rails のログを grep しやすくするプログラムです。
grep(1) に比べて以下の点で優れています。

- 行単位ではなくリクエスト単位でマッチできる
- さらに、マッチしたリクエストの前後のリクエストも表示できる

## Install

GitHub から実行ファイルをダウンロードしてください。
必要であれば実行権限をつけて $PATH の通ったところに配置してください。

    $ curl -O https://raw.github.com/kyanny/rails-log-block-grep/master/rails-log-block-grep.rb

## Usage

Ruby が必要です。 1.8.7 と 1.9.2 で動作を確認しています。
具体的な実行方法はヘルプを参照してください。

    $ ruby rails-log-block-grep.rb -h

## Issues

もし不具合をみつけたら、 [https://github.com/kyanny/rails-log-block-grep/issues](https://github.com/kyanny/rails-log-block-grep/issues) にご連絡ください。

## Author

Kensuke Nagae <kyanny at gmail dot com>
