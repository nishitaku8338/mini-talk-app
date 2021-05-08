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


messages_controller.rbを編集
メッセージの保存が成功したときに、
broadcastを介してメッセージが送信されるように記述します。
app/controller/messages_controller.rb
class MessagesController < ApplicationController
  def new
    @messages = Message.all
    @message = Message.new
  end

  def create
    @message = Message.new(text: params[:message][:text])
    if @message.save
      ActionCable.server.broadcast 'message_channel', content: @message
    end
  end
end


追記した10行目は、broadcastを通して、
'message_channel'に向けて@messageを送信するということです。
送信された情報は、message_channel.jsで受け取ります。



message_channel.jsを編集
受け取った情報は、receivedの引数dataに入ります。
このデータをテンプレートリテラルにして、new.html.erbに挿入しましょう。
以下のように編集してください。

app/javascript/channels/message_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("MessageChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const html = `<p>${data.content.text}</p>`;
    const messages = document.getElementById('messages');
    const newMessage = document.getElementById('message_text');
    messages.insertAdjacentHTML('afterbegin', html);
    newMessage.value='';
  }
});

13行目で受け取ったdataのなかにあるcontentのなかのtextを表示します。
contentはコントローラーのcreateアクション内で指定したcontentからきています。
contentは@messageと同義なので、textを取り出せるというわけです。

ここまで実装出来たら、localhost:3000に接続して、実際にメッセージを送信して確かめましょう。
以下のような表示がされていれば成功です。

