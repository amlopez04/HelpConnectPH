class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  
  def index
    # Use Pundit policy scope to filter reports based on user role
    @reports = policy_scope(Report).includes(:user, :barangay, :category)
    
    # Filter by status if provided
    if params[:status].present?
      @reports = @reports.where(status: params[:status])
    end
    
    @reports = @reports.order(created_at: :desc)
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
      redirect_to @report, notice: "Report was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    authorize @report
  end
  
  def update
    authorize @report
    
    if @report.update(report_params)
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
  
  private
  
  def set_report
    @report = Report.find(params[:id])
  end
  
  def report_params
    params.require(:report).permit(:title, :description, :address, :barangay_id, :category_id, :priority, :status, photos: [])
  end
end

