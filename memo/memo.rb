Action Cableの実装
メッセージを即時更新する機能を、Action Cableを用いて実装します。

Action Cable
Action Cableは、通常のRailsのアプリケーションと同様の記述で、
即時更新機能を実装できるフレームワークです。
実装内容としては、メッセージの保存や送信に必要なRubyのコーディングと、
保存したメッセージを即時に表示させるJavaScriptのコーディングです。

メッセージを即座に表示させよう
メッセージを即座に表示させるために、
データの経路を設定したり、送られてきたデータを表示させるJavaScriptを記述したりします。
これらの役割をChannel（チャネル）が担っています。

Channel（チャネル）
チャネルとは、即時更新機能を実現するサーバー側の仕組みのことをいいます。
上記に示した通り、データの経路を設定したり、送られてきたデータをクライアントの画面上に表示させたりします。


チャネルを作成しましょう
以下のコマンドを実行してチャネルに関するファイルを作成します。
ターミナル
rails g channel message

以下のようにファイルが生成されます。
ターミナル
Running via Spring preloader in process 11084
      invoke  test_unit
      create  test/channels/message_channel_test.rb
      create  app/channels/message_channel.rb
  identical  app/javascript/channels/index.js
  identical  app/javascript/channels/consumer.js
      create  app/javascript/channels/message_channel.js


生成された、
app/channels/message_channel.rb、
app/javascript/channels/message_channel.js、
が重要なファイルです。
今回の実装での、それぞれのファイルの役割を解説します。

message_channel.rbの役割
このファイルは、クライアントとサーバーを結びつけるためのファイルです。

message_channel.jsの役割
このファイルは、サーバーから送られてきたデータをクライアントの画面に描画するためのファイルです。

これらを編集しながら実装を進めます。



message_channel.rbを編集
このファイルは、サーバーとクライアントを繋ぐファイルです。
MVCでいうところのルーティングの機能を果たします。
stream_fromメソッドを用いることで、サーバーとクライアントの関連付けを設定します。


stream_from
stream_fromとは、サーバーとクライアントを関連付けるメソッドです。
Action Cableにあらかじめ用意されています。

まずは、message_channel.rbに以下を追記しましょう。
app/channels/message_channel.rb
class MessageChannel < ApplicationCable::Channel
  def subscribed
    stream_from "message_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end


これでサーバーとクライアントを関連付けるための設定ができました。
以下の図の赤く示している箇所です。
stream_fromメソッドで関連付けられるデータの経路のことを、
broadcast（ブロードキャスト）と呼びます。

broadcast（ブロードキャスト）
broadcastとは、サーバーから送られるデータの経路のことを指します。
broadcastを介してデータをクライアントに送信します。