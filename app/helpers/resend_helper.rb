# Helper module for sending emails via Resend API directly
module ResendHelper
  def self.send_email(to:, subject:, html: nil, text: nil, from: nil)
    require 'resend'
    
    # Set API key
    Resend.api_key = ENV['RESEND_API_KEY']
    
    # Default from address
    from ||= "ParañaqueConnect <paranaqueconnect@deidei.tech>"
    
    # Prepare parameters
    params = {
      "from": from,
      "to": Array(to), # Ensure it's an array
      "subject": subject
    }
    
    # Add content
    if html.present?
      params["html"] = html
    end
    
    if text.present?
      params["text"] = text
    end
    
    # Send via Resend
    result = Resend::Emails.send(params)
    
    Rails.logger.info "ResendHelper: Email sent successfully - ID: #{result['id']}"
    
    result
  end
end
