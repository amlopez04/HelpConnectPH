class Admin::BarangayCaptainsController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize [ :admin, :barangay_captain ], :new?

    # Require barangay_id parameter
    unless params[:barangay_id].present?
      redirect_to barangays_path, alert: "Please select a barangay first to create a captain account."
      return
    end

    @barangay = Barangay.find_by(id: params[:barangay_id])

    # Check if barangay exists
    unless @barangay
      redirect_to barangays_path, alert: "Barangay not found."
      return
    end

    # Check if barangay already has a captain
    if @barangay.users.barangay_official.any?
      redirect_to barangay_path(@barangay), alert: "This barangay already has a captain assigned."
      return
    end

    @user = User.new(barangay_id: @barangay.id)
  end

  def create
    authorize [ :admin, :barangay_captain ], :create?

    # Generate secure random password (alphanumeric + symbols, 8 characters)
    generated_password = ApplicationHelper.generate_secure_password

    @user = User.new(
      email: params[:user][:email],
      role: :barangay_official,
      barangay_id: params[:user][:barangay_id]
    )

    # Set password explicitly
    @user.password = generated_password
    @user.password_confirmation = generated_password

    # Skip confirmation emails and auto-confirm the account
    @user.skip_confirmation!

    if @user.save
      # Send welcome email to the new captain
      ReportMailer.welcome_captain(@user).deliver_now

      # DEBUG: Verify password was saved correctly
      Rails.logger.info "=== Captain Account Created ==="
      Rails.logger.info "Email: #{@user.email}"
      Rails.logger.info "Confirmed?: #{@user.confirmed?}"
      Rails.logger.info "Password Valid?: #{@user.valid_password?(generated_password)}"
      Rails.logger.info "================================"

      # Store credentials in session with string keys (Rails session serialization works better with strings)
      session[:captain_credentials] = {
        "email" => @user.email,
        "password" => generated_password,
        "barangay_name" => @user.barangay.name
      }
      redirect_to dashboard_path, notice: "Barangay Captain account created successfully!"
    else
      # Reload available barangays for form
      barangays_with_captains = User.where(role: :barangay_official).pluck(:barangay_id)
      @available_barangays = Barangay.where.not(id: barangays_with_captains).order(:name)
      render :new, status: :unprocessable_entity
    end
  end
end
