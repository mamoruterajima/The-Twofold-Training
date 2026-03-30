class AddRepsToTrainingLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :training_logs, :reps1, :integer
    add_column :training_logs, :reps2, :integer
    add_column :training_logs, :reps3, :integer
  end
end
