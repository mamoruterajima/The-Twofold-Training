class CreateTrainingLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :training_logs do |t|
      t.date :workout_date
      t.string :body_part
      t.string :exercise_name
      t.float :weight
      t.integer :reps
      t.integer :sets
      t.integer :interval
      t.text :memo

      t.timestamps
    end
  end
end
