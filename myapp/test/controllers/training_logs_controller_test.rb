require "test_helper"

class TrainingLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @training_log = training_logs(:one)
  end

  test "should get index" do
    get training_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_training_log_url
    assert_response :success
  end

  test "should create training_log" do
    assert_difference("TrainingLog.count") do
      post training_logs_url, params: { training_log: { body_part: @training_log.body_part, exercise_name: @training_log.exercise_name, interval: @training_log.interval, memo: @training_log.memo, reps: @training_log.reps, sets: @training_log.sets, weight: @training_log.weight, workout_date: @training_log.workout_date } }
    end

    assert_redirected_to training_log_url(TrainingLog.last)
  end

  test "should show training_log" do
    get training_log_url(@training_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_training_log_url(@training_log)
    assert_response :success
  end

  test "should update training_log" do
    patch training_log_url(@training_log), params: { training_log: { body_part: @training_log.body_part, exercise_name: @training_log.exercise_name, interval: @training_log.interval, memo: @training_log.memo, reps: @training_log.reps, sets: @training_log.sets, weight: @training_log.weight, workout_date: @training_log.workout_date } }
    assert_redirected_to training_log_url(@training_log)
  end

  test "should destroy training_log" do
    assert_difference("TrainingLog.count", -1) do
      delete training_log_url(@training_log)
    end

    assert_redirected_to training_logs_url
  end
end
