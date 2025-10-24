class Admin::BarangayCaptainsController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize [:admin, :barangay_captain], :new?
    
    # Get barangays that don't have a captain yet
    barangays_with_captains = User.where(role: :barangay_official).pluck(:barangay_id)
    @available_barangays = Barangay.where.not(id: barangays_with_captains).order(:name)
    
    @user = User.new
  end

  def create
    authorize [:admin, :barangay_captain], :create?
    
    # Set default password (all captains get same password initially)
    generated_password = "Captain2024!"
    
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
        'email' => @user.email,
        'password' => generated_password,
        'barangay_name' => @user.barangay.name
      }
      redirect_to dashboard_path, notice: 'Barangay Captain account created successfully!'
    else
      # Reload available barangays for form
      barangays_with_captains = User.where(role: :barangay_official).pluck(:barangay_id)
      @available_barangays = Barangay.where.not(id: barangays_with_captains).order(:name)
      render :new, status: :unprocessable_entity
    end
  end
end

