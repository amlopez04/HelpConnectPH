class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [:show, :edit, :update, :destroy, :approve, :reject]
  
  def index
    # Use Pundit policy scope to filter reports based on user role
    @reports = policy_scope(Report).includes(:user, :barangay, :category)
    
    # Filter by status if provided
    if params[:status].present?
      @reports = @reports.where(status: params[:status])
    end
    
    @reports = @reports.order(created_at: :desc).page(params[:page]).per(10)
  end
  
  def show
    authorize @report
    @report.comments.reload # Ensure comments are loaded
  end
  
  def new
    @report = Report.new
    authorize @report
  end
  
  def create
    @report = current_user.reports.build(report_params)
    authorize @report
    
    if @report.save
      # Send email notification to admin for approval (not to barangay captain yet)
      ReportMailer.admin_new_report_notification(@report).deliver_now
      
      redirect_to @report, notice: "Report was successfully submitted and is pending admin approval."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    authorize @report
  end
  
  def update
    authorize @report
    
    old_status = @report.status
    if @report.update(report_params)
      # Send email notification if status changed
      if old_status != @report.status
        ReportMailer.status_change_notification(@report, old_status).deliver_now
      end
      redirect_to @report, notice: "Report was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    authorize @report
    @report.destroy
    redirect_to reports_path, notice: "Report was successfully deleted."
  end

  # Admin approval action
  def approve
    authorize @report, :update?
    
    if @report.update(status: :pending)
      # Now send email to barangay captain after approval
      ReportMailer.new_report_notification(@report).deliver_now
      
      # Send confirmation email to report creator
      ReportMailer.report_approved_notification(@report).deliver_now
      
      redirect_to @report, notice: "Report approved and sent to barangay captain."
    else
      redirect_to @report, alert: "Failed to approve report."
    end
  end

  # Admin rejection action
  def reject
    authorize @report, :update?
    
    if @report.update(status: :closed)
      # Send rejection email to report creator
      ReportMailer.report_rejected_notification(@report).deliver_now
      
      redirect_to @report, notice: "Report rejected and closed."
    else
      redirect_to @report, alert: "Failed to reject report."
    end
  end
  
  private
  
  def set_report
    @report = Report.find(params[:id])
  end
  
  def report_params
    params.require(:report).permit(:title, :description, :address, :latitude, :longitude, :barangay_id, :category_id, :priority, :status, photos: [])
  end
end

