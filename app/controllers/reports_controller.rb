class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [ :show, :edit, :update, :destroy, :approve, :reject, :request_reopen, :approve_reopen, :update_status ]

  def index
    # Use Pundit policy scope to filter reports based on user role
    @reports = policy_scope(Report).includes(:user, :barangay, :category)

    # Resident "My Reports" filter
    if current_user&.resident? && params[:my_reports] == "true"
      @reports = @reports.where(user_id: current_user.id)
    end

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

    # Admin search filter
    if current_user&.admin? && params[:search].present?
      search_term = "%#{params[:search]}%"
      @reports = @reports.where(
        "reports.title ILIKE ? OR reports.description ILIKE ? OR reports.address ILIKE ?",
        search_term, search_term, search_term
      )
    end

    # Admin spam filter
    if current_user&.admin? && params[:spam].present? && params[:spam] == "true"
      # Load reports efficiently and check for spam
      spam_ids = []
      @reports.find_each do |report|
        spam_ids << report.id if report.potential_spam?
      end
      @reports = @reports.where(id: spam_ids) if spam_ids.any?
      @reports = @reports.none if spam_ids.empty?
    end

    @reports = @reports.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    authorize @report
    @report.comments.includes(:user).reload # Ensure comments with users are loaded
  end

  def new
    @report = Report.new
    authorize @report
  end

  def create
    @report = current_user.reports.build(report_params)
    authorize @report

    # Ensure default priority is medium unless explicitly set by officials/admins
    if @report.priority.blank? || current_user&.resident?
      @report.priority = :medium
    end

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

    if @report.update(status: :resolved)
      # Send rejection email to report creator
      ReportMailer.report_rejected_notification(@report).deliver_now

      redirect_to @report, notice: "Report rejected and marked as resolved."
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

  # Quick status update for officials/admins
  def update_status
    authorize @report, :update?

    new_status = params[:status]
    old_status = @report.status

    if Report.statuses.key?(new_status.to_sym)
      if @report.update(status: new_status)
        # Set resolved_at if status is resolved
        if new_status.to_sym == :resolved
          @report.update(resolved_at: Time.current) unless @report.resolved_at.present?
        end

        # Send email notification to report creator if status changed
        if old_status != new_status
          ReportMailer.status_change_notification(@report, old_status).deliver_now
        end

        redirect_to @report, notice: "Report status updated to #{new_status.titleize}."
      else
        redirect_to @report, alert: "Failed to update status."
      end
    else
      redirect_to @report, alert: "Invalid status."
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
