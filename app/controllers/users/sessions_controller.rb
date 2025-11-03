class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    # Pre-check for banned accounts to provide a clearer message
    email = params.dig(:user, :email).to_s.downcase
    user = User.find_by(email: email)

    if user&.banned_at.present?
      reason = user.ban_reason.presence || "Violation of community guidelines"
      # Use Devise failure scope for consistent i18n and flash handling
      flash[:alert] = I18n.t("devise.failure.banned", reason: reason)
      redirect_to new_user_session_path and return
    end

    super
  end
end
