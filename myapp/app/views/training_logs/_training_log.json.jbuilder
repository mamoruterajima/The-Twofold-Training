json.extract! training_log, :id, :workout_date, :body_part, :exercise_name, :weight, :reps, :sets, :interval, :memo, :created_at, :updated_at
json.url training_log_url(training_log, format: :json)
