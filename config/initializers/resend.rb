# Resend configuration
Rails.application.configure do
  # Set Resend API key
  if ENV["RESEND_API_KEY"].present?
    Resend.api_key = ENV["RESEND_API_KEY"]
  else
    Rails.logger.warn "RESEND_API_KEY not found in environment variables"
  end
end
