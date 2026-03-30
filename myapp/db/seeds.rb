# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# 種目リストを定義
exercises = {
  "胸" => ["ベンチプレス", "インクラインダンベルプレス", "ディップス", "ペックフライ"],
  "背中" => ["デッドリフト", "懸垂", "ベントオーバーロウ", "ラットプルダウン", "シーテッドケーブルロウ"],
  "足" => ["バーベルスクワット", "バーベルカーフレイズ", "ダンベルランジ右", "ダンベルランジ左"],
  "肩" => ["サイドレイズ", "リアレイズ", "フェイスプル", "ショルダープレス",  "アップライトロウ"],
  "腕" => ["EZバーカール", "バーベルカール", "インクラインカール", "ハンマーカール", "ライイングエクステンション", "ケーブルプルオーバー", "リバースEZバーカール", "リバースリストカール"],
  "腹" => ["アブローラー", "ドラゴンフラッグ"]
}