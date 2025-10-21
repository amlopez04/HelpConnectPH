class DashboardsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    case current_user.role
    when 'resident'
      @my_reports = current_user.reports.order(created_at: :desc).limit(5)
      # Residents can see all community reports (using policy scope)
      @recent_reports = policy_scope(Report).includes(:user, :category, :barangay).order(created_at: :desc).limit(10)
      render :resident
    when 'barangay_official'
      if current_user.barangay
        @barangay = current_user.barangay
        # Barangay officials only see reports from their barangay (using policy scope)
        @pending_reports = policy_scope(Report).pending.includes(:user, :category).order(created_at: :desc)
        @in_progress_reports = policy_scope(Report).in_progress.count
        @resolved_reports = policy_scope(Report).resolved.count
      end
      render :barangay_official
    when 'admin'
      # Admins see all reports (policy scope returns all for admins)
      @total_reports = Report.count
      @pending_reports = Report.pending.count
      @in_progress_reports = Report.in_progress.count
      @resolved_reports = Report.resolved.count
      @total_barangays = Barangay.count
      @total_categories = Category.count
      @recent_reports = policy_scope(Report).includes(:user, :category, :barangay).order(created_at: :desc).limit(10)
      
      # Barangay Captain statistics
      @barangays_with_captains = User.where(role: :barangay_official).includes(:barangay).pluck(:barangay_id)
      @total_captains = @barangays_with_captains.count
      @barangays_without_captains = Barangay.where.not(id: @barangays_with_captains).order(:name)
      
      # For testing: List all created captain accounts
      @barangay_captains = User.where(role: :barangay_official).includes(:barangay).order(created_at: :desc)
      
      # Retrieve captain credentials from session if available
      @captain_credentials = session.delete(:captain_credentials)
      
      render :admin
    else
      redirect_to root_path, alert: "Invalid user role"
    end
  end
end

