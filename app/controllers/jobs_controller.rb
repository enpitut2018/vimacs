class JobsController < ApplicationController
  before_action :set_job, only: [:chat, :worker_list, :create_message, :show, :edit, :update, :destroy]

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.all
    @users = User.all
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @chat_list = Chat.where(job_id: @job.id)
    @employer = User.find_by(id: @job.user_id)
    @jobcomments = Jobcomment.all
    @jobcomment = Jobcomment.new

  end

  # GET /jobs/new
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def create_message
    @chat = Chat.new()
    @chat.message = params.require(:message)
    @chat.from_id = params.require(:from_id)
    @chat.to_id = params.require(:to_id)
    @chat.job_id = @job.id
    @chat.save()
    redirect_back fallback_location: root_path
  end

  def worker_list
    p Chat.where(to_id: current_user.id, job_id: @job.id)
    result= Chat.where(to_id: current_user.id, job_id: @job.id).select(:from_id).uniq
    hoge=[];
    result.each do |e|
      hoge.push(e.from_id)
    end

    @workers = User.find(hoge)
  end

  def chat
    @worker_id = params.require(:worker_id)
    @chat_list = Chat.where(job_id: @job.id)
    p @chat_list
    @chat_list=@chat_list.where(from_id: current_user.id,to_id: @worker_id).or(@chat_list.where(from_id: @worker_id,to_id: current_user.id))
    @chat_list.reorder(:timestamp)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
      @jobcomment = Jobcomment.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:title, :user_id, :description)
    end
end
