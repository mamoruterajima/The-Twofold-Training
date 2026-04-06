class TrainingLogsController < ApplicationController
  before_action :set_training_log, only: %i[ show edit update destroy ]

  # GET /training_logs or /training_logs.json
  def index
    @training_logs = current_user.training_logs
  
  if params[:body_part].present?
    # URLに部位が指定されていたら、その部位だけで絞り込む
    @training_logs = @training_logs.where(body_part: params[:body_part]).order(workout_date: :desc)
  else
    # 指定がなければ全部出す（日付が新しい順）
    @training_logs = @training_logs.all.order(workout_date: :desc)  # 一旦全期間集計。今後運用して調整
  end
end
  def last_record
    # 種目名で検索して、最新の1件を取得
    record = @training_logs.where(exercise_name: params[:exercise_name]).order(workout_date: :desc).first
    
    # データをJSONで返す（データがない場合は null が返る）
    render json: record
  end

  # GET /training_logs/1 or /training_logs/1.json
  def show
  end

  # GET /training_logs/new
  def new
    @training_log = TrainingLog.new(workout_date: Date.today) # ここに今日の日付をセット
  end

  # GET /training_logs/1/edit
  def edit
  end

  # POST /training_logs or /training_logs.json
  def create
    @training_log = current_user.training_logs.build(training_log_params)

    respond_to do |format|
      if @training_log.save
        format.html { redirect_to @training_log, notice: "Training log was successfully created." }
        format.json { render :show, status: :created, location: @training_log }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /training_logs/1 or /training_logs/1.json
  def update
    respond_to do |format|
      if @training_log.update(training_log_params)
        format.html { redirect_to @training_log, notice: "Training log was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @training_log }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_logs/1 or /training_logs/1.json
  def destroy
    @training_log.destroy!

    respond_to do |format|
      format.html { redirect_to training_logs_path, notice: "Training log was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_training_log
      @training_log = TrainingLog.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def training_log_params
      params.expect(training_log: [ :workout_date, :body_part, :exercise_name, :weight, :reps1, :reps2, :reps3, :sets, :interval, :memo ])
    end
end