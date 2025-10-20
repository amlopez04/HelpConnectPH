class ReportsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  
  def index
    @reports = Report.all.includes(:user, :barangay, :category).order(created_at: :desc)
  end
  
  def show
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

