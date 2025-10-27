class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [ :show, :edit, :update, :destroy, :approve, :reject, :request_reopen, :approve_reopen ]

  def index
    # Use Pundit policy scope to filter reports based on user role
    @reports = policy_scope(Report).includes(:user, :barangay, :category)

    # Filter by status if provided
    if params[:status].present?
      @reports = @reports.where(status: params[:status])
    end

    # Filter by category if provided
    if params[:category_id].present?
      @reports = @reports.where(category_id: params[:category_id])
    end

    # Admin location filter: filter by barangay
    if current_user&.admin? && params[:barangay_id].present?
      @reports = @reports.where(barangay_id: params[:barangay_id])
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

  # Request to reopen closed report
  def request_reopen
    authorize @report

    if (@report.closed? || @report.resolved?) && @report.user == current_user
      @report.update(status: :reopen_requested)
      # Send email notification to admins
      ReportMailer.reopen_request_notification(@report).deliver_now
      flash[:notice] = "Request to reopen case has been submitted to admin for approval."
      redirect_to @report
    else
      redirect_to @report, alert: "You can only request to reopen your own closed or resolved reports."
    end
  end

  # Admin approve reopen request
  def approve_reopen
    authorize @report, :update?

    if @report.reopen_requested?
      @report.update(status: :pending)
      # Send email notification to report creator
      ReportMailer.reopen_approved_notification(@report).deliver_now
      flash[:notice] = "Report has been reopened and set to pending status."
      redirect_to @report
    else
      redirect_to @report, alert: "This report is not awaiting reopen approval."
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
