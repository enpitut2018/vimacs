class AssignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_assign, only: [:show, :edit, :update, :destroy, :review]

  # GET /assigns
  # GET /assigns.json
  def index
    @assigns = Assign.all
  end

  # GET /assigns/1
  # GET /assigns/1.json
  def show
  end

  # GET /assigns/new
  def new
    @assign = Assign.new
  end

  # GET /assigns/1/edit
  def edit
  end

  # POST /assigns
  # POST /assigns.json
  def create
    @assign = Assign.new(assign_params)
    if current_user.id != @assign.user_id
      respond_to do |format|
        format.html { redirect_to root_path, notice: '参加する権限がありません' }
        format.json { head :no_content }
      end
    elsif (job = Job.find_by(id: params[:assign][:job_id])) != nil and job.user_id == @assign.user_id
      respond_to do |format|
        format.html { redirect_to root_path, notice: '自分の仕事には参加できません' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        if @assign.save
          format.html { redirect_to @assign.job, notice: '参加しました' }
          format.json { render :show, status: :created, location: @assign }
        else
          format.html { redirect_to root_path }
          format.json { render json: @assign.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /assigns/1
  # PATCH/PUT /assigns/1.json
  def update
    status = assign_params[:status]
    isWorker = current_user.id == @assign.user_id
    isOwner = current_user.id == @assign.job.user_id
    if (status == 'applying' && isWorker) ||
       (status == 'join'     && isOwner) ||
       (status == 'complete' && isOwner)
      respond_to do |format|
        if @assign.update(assign_params)
          if isOwner
            format.html { redirect_to "/jobs/" + @assign.job.id.to_s + "#userlist"}
          else
            format.html { redirect_back fallback_location: root_path }
          end
          format.json { render :show, status: :ok, location: @assign }
        else
          format.html { redirect_to root_path }
          format.json { render json: @assign.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, notice: '変更する権限がありません' }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /assigns/1
  # DELETE /assigns/1.json
  def destroy
    if current_user.id != @assign.user_id
      respond_to do |format|
        format.html { redirect_to root_path, notice: '削除する権限がありません' }
        format.json { head :no_content }
      end
    else
      @assign.destroy
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  def review

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assign
      @assign = Assign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assign_params
      params.require(:assign).permit(:job_id, :user_id, :status)
    end
end
