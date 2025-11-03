class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_user, only: [ :ban, :unban, :soft_delete, :restore ]

  def index
    @users = User.all
    if params[:role].present? && User.roles.key?(params[:role])
      @users = @users.where(role: User.roles[params[:role]])
    end

    # Status filter: active, banned, deleted
    case params[:status]
    when "active"
      @users = @users.where(banned_at: nil, deleted_at: nil)
    when "banned"
      # Show only users who are currently banned (not deleted)
      @users = @users.where.not(banned_at: nil).where(deleted_at: nil)
    when "deleted"
      # Show only users who are deleted; exclude banned to avoid overlap in filters
      @users = @users.where.not(deleted_at: nil).where(banned_at: nil)
    end

    # Search by email or phone
    if params[:search].present?
      term = "%#{params[:search]}%"
      @users = @users.where("users.email ILIKE ? OR users.phone_number ILIKE ?", term, term)
    end

    @users = @users.order(created_at: :desc).page(params[:page]).per(20)
    @banned_count = User.where.not(banned_at: nil).count
    @deleted_count = User.where.not(deleted_at: nil).count
    @active_count = User.active.count
  end

  def show
    @user = User.find(params[:id])
    authorize_admin_view

    # Ordered list for display
    @reports = @user.reports.includes(:category, :barangay).order(created_at: :desc)
    @total_reports = @reports.size # Use .size for already-loaded relation
    # Separate grouped query without ORDER BY to avoid PG grouping error
    @status_counts = @user.reports.group(:status).count

    # Spam metrics
    @potential_spam_count = 0
    @gibberish_count = 0
    @user.reports.find_each do |report|
      @potential_spam_count += 1 if report.potential_spam?
      @gibberish_count += 1 if report.random_gibberish?(report.description)
    end
  end

  def banned
    @users = User.where.not(banned_at: nil).order(banned_at: :desc).page(params[:page]).per(20)
    @banned_count = @users.count
    @deleted_count = User.where.not(deleted_at: nil).count
    @active_count = User.active.count
  end

  def ban
    unless @user.resident?
      return redirect_to admin_users_path, alert: "Only resident accounts can be banned."
    end

    reason = params[:reason] || "Violation of community guidelines"
    @user.ban!(reason: reason)
    redirect_to admin_users_path, notice: "#{@user.email} has been banned."
  end

  def unban
    @user.unban!
    redirect_to admin_users_path, notice: "#{@user.email} has been unbanned."
  end

  def soft_delete
    @user.soft_delete!
    redirect_to admin_users_path, notice: "#{@user.email} has been deactivated."
  end

  def restore
    @user.restore!
    redirect_to admin_users_path, notice: "#{@user.email} has been restored."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def authorize_admin_view
    ensure_admin
  end
end
