class DropTasks < ActiveRecord::Migration[8.0]
  def change
    drop_table :tasks, if_exists: true
  end
end