# Custom Resend delivery method for ActionMailer
class ResendDeliveryMethod
  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    require "resend"

    # Set API key
    Resend.api_key = @settings[:api_key] || ENV["RESEND_API_KEY"]

    # Debug logging
    Rails.logger.info "ResendDeliveryMethod: Sending email to #{mail.to}"
    Rails.logger.info "ResendDeliveryMethod: From #{mail.from}"
    Rails.logger.info "ResendDeliveryMethod: Subject #{mail.subject}"

    # Convert ActionMailer mail to Resend format
    params = {
      "from": mail.from.first,
      "to": mail.to,
      "subject": mail.subject,
      "html": mail.html_part&.body&.to_s || mail.body.to_s
    }

    # Add text content if available
    if mail.text_part
      params["text"] = mail.text_part.body.to_s
    end

    Rails.logger.info "ResendDeliveryMethod: Sending with params #{params}"

    # Send via Resend
    result = Resend::Emails.send(params)

    Rails.logger.info "ResendDeliveryMethod: Result #{result}"

    # Return a mock delivery result
    OpenStruct.new(
      message_id: result["id"],
      response: result
    )
  end
end

# Register the custom delivery method
ActionMailer::Base.add_delivery_method :resend, ResendDeliveryMethod
