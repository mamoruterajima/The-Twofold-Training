// app/javascript/controllers/exercise_select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ターゲットを3つ正確に指定
  static targets = ["category", "exercise", "lastRecordDisplay"]

  connect() {
    this.updateExercises()
  }

  updateExercises() {
    const exercises = {
      "胸": ["ベンチプレス", "インクラインプレス", "ディップス", "ペックフライ"],
      "背中": ["デッドリフト", "懸垂", "ベントオーバーロウ", "ラットプルダウン", "シーテッドケーブルロウ"],
      "足": ["バーベルスクワット", "バーベルカーフレイズ", "ダンベルランジ右", "ダンベルランジ左"],
      "肩": ["サイドレイズ", "リアレイズ", "フェイスプル", "ショルダープレス", "アップライトロウ"],
      "腕": ["EZバーカール", "バーベルカール", "インクラインカール", "ハンマーカール", "ライイングエクステンション", "ケーブルプルオーバー", "リバースEZバーカール", "リバースリストカール"],
      "腹": ["アブローラー", "ドラゴンフラッグ"]
    }

    const selectedCategory = this.categoryTarget.value
    const options = exercises[selectedCategory] || []

    this.exerciseTarget.innerHTML = ""

    options.forEach(exercise => {
      const option = document.createElement("option")
      option.value = exercise
      option.text = exercise
      this.exerciseTarget.appendChild(option)
    })

    // 種目をセットした直後に前回記録を取りに行く
    this.fetchLastRecord()
  }

  async fetchLastRecord() {
    const exerciseName = this.exerciseTarget.value
    if (!exerciseName) {
      this.lastRecordDisplayTarget.innerHTML = ""
      return
    }

    try {
      const response = await fetch(`/training_logs/last_record?exercise_name=${encodeURIComponent(exerciseName)}`)
      const data = await response.json()

      if (data && data.weight) {
        this.lastRecordDisplayTarget.innerHTML = 
          `前回記録: <strong>${data.weight}kg × ${data.reps}rep</strong> (${data.workout_date})`
      } else {
        this.lastRecordDisplayTarget.innerHTML = "前回記録なし"
      }
    } catch (error) {
      console.error("Error fetching record:", error)
    }
  }
}