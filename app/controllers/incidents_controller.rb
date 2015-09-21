class IncidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [ :index,:new, :create, :show]
  before_action :set_incident, only: [:show]

  respond_to :html, :json, only: [:index, :new, :show,:view_incident]

  # GET /incidents
  # GET /incidents.json
  def index
    @incidents = @project.incidents
    respond_with @incidents
  end

  def view_incident
    @incident = Incident.find(params[:id])
    respond_with @incident
  end

  # GET /incidents/1
  # GET /incidents/1.json
  def show
    # respond_with @incident
  end

  # GET /incidents/new
  def new
    @incident = Incident.new
    @incident.your_name = current_user.first_name ||  current_user.last_name || ''
    respond_with @incident
  end

  # GET /incidents/1/edit
  # def edit
  #   respond_with @incident
  #   respond_with @incident
  def empty_incident
    project = Project.find(params[:project_id])
    incident = project.incidents.build
    incident.save!
    return render :json=> incident
  end
  # end
  def upload_image
    # project = Project.find(params[:project_id])
    incident = Incident.find(params[:id])
    incident.file = uploaded_picture(params[:incident][:file]) if params[:incident][:file].present?
    incident.save!
    return render :json=>{url: incident.file_url}
  end



  # POST /incidents
  # POST /incidents.json
  def create
    if(params[:incId]).present?
      @incident = Incident.find(params[:incId])
      @incident.report_type = params[:incident][:report_type] 
      @incident.your_name = params[:incident][:your_name]
      @incident.job_title = params[:incident][:job_title]
      @incident.injury_date = params[:incident][:injury_date]
      @incident.injury_time = params[:incident][:injury_time]
      @incident.witnesses = params[:incident][:witnesses]
      @incident.location =params[:incident][:location]
      @incident.circumstances =  params[:incident][:circumstances]
      @incident.event_discription = params[:incident][:event_discription]
      @incident.injuries_type =params[:incident][:injuries_type]
      @incident.ppe_used =params[:incident][:ppe_used]
      @incident.medical_assistance_provided =params[:incident][:medical_assistance_provided]
    else
      @incident = @project.incidents.build(incident_params)
    end

    respond_to do |format|
      if @incident.save
        @incident.cn = true
        @incident.save!
        incidents = @project.incidents.where(cn: false)
        incidents.destroy_all if incidents.present?
        format.html { redirect_to projects_path({inc: @incident.id}), notice: 'Incident was successfully created.' }
        format.json {  render json: :true}  
        # format.json { render action: 'show', status: :created, location: @incident }
      else
        format.html { render action: 'new' }
        format.json { render json: :true}
        # format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

    def send_email
      question = Question.find(params[:qid])
      answer = Answer.where(question_id: params[:qid], report_id: params[:id]).first
      report = Report.find(params[:id])
      project = report.project
      category = question.category
      to = params[:email]

      id = params[:id]
      aa = UserMailer.send_incident_report(current_user,question.body,project.name,category.name,answer,to).deliver
      # flash[:success] = "Email sent successfully."
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render json: :true }
      end
  end

  # PATCH/PUT /incidents/1
  # PATCH/PUT /incidents/1.json
  # def update
  #   respond_to do |format|
  #     if @incident.update(incident_params)
  #       format.html { redirect_to projects_path, notice: 'Incident was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @incident.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /incidents/1
  # # DELETE /incidents/1.json
  # def destroy
  #   @incident.destroy
  #   respond_to do |format|
  #     format.html { redirect_to project_incidents_url(@project) }
  #     format.json { head :no_content }
  #   end
  # end

  def send_new_incident
    @incident = Incident.find(params[:id])
    respond_to do |format|
      format.html
      format.json
      format.pdf do
        # if @incident.downloaded.blank?
          pdf = IncidentPdf.new(@incident)
          if @incident.file.present?
            file = "#{Rails.root}/public#{@incident.file_url}"
            pdf.image file, :fit => [450,350]
          end 
          @incident.update!(downloaded: true)
          send_data pdf.render, filename: "(Your new Incident on project #{@incident.project.name}).pdf", type: "application/pdf", disposition: "attachment"
        # else
          # redirect_to projects_path
        # end
      end
    end
  end

  private

    def uploaded_picture(base64)

      tempfile = Tempfile.new ['upload', '.jpg']
      tempfile.binmode
      tempfile.write(Base64.decode64(base64))

      # ActionDispatch::Http::UploadedFile.new(tempfile: tempfile,
      #   filename: 'upload.jpg')
      tempfile
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_user.whole_projects.find(params[:project_id])
    end
    def set_incident
      @incident = @project.incidents.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def incident_params
      params.require(:incident).permit(:report_type, :your_name, :job_title, :injury_date, :injury_time, :witnesses, :location, :circumstances, :event_discription, :injuries_type, :ppe_used, :medical_assistance_provided, :project_id,:file)
    end
end
