class ReportMailer < Devise::Mailer
  # Email sent to barangay captain when a new report is created
  def new_report_notification(report)
    @report = report
    
    # Only send email if report has a barangay and that barangay has a captain
    return unless @report.barangay.present?
    
    @barangay_captain = @report.barangay.users.find_by(role: :barangay_official)
    
    # Only send email if there's a captain for this barangay
    return unless @barangay_captain.present?
    
    mail(
      to: [@barangay_captain.email],
      subject: "🚨 New Report: #{@report.title} - #{@report.barangay.name}"
    )
  end

  # Email sent to report creator when status changes
  def status_change_notification(report, old_status)
    @report = report
    @old_status = old_status
    @new_status = report.status
    
    mail(
      to: [@report.user.email],
      subject: "📋 Report Update: #{@report.title} - Status Changed to #{@new_status.titleize}"
    )
  end

  # Email sent to report creator when a new comment is added
  def new_comment_notification(report, comment)
    @report = report
    @comment = comment
    @commenter = comment.user
    
    # Don't notify the report creator if they commented on their own report
    return if @commenter == @report.user
    
    mail(
      to: [@report.user.email],
      subject: "💬 New Comment on Your Report: #{@report.title}"
    )
  end

  # Welcome email for new barangay captain accounts
  def welcome_captain(captain)
    @captain = captain
    @barangay = captain.barangay
    
    # Only send email if captain has a barangay assigned
    return unless @barangay.present?
    
    mail(
      to: [@captain.email],
      subject: "👋 Welcome to ParañaqueConnect - Barangay Captain Account"
    )
  end

  # Welcome email for new resident registration (with confirmation)
  def welcome_resident(resident)
    @resident = resident
    
    mail(
      to: [@resident.email],
      subject: "👋 Welcome to ParañaqueConnect - Your Account is Ready!"
    )
  end

  # Confirmation + Welcome email for new resident registration
  def confirmation_and_welcome(resident, confirmation_token)
    @resident = resident
    @confirmation_token = confirmation_token
    
    mail(
      to: [@resident.email],
      subject: "📧 Welcome to ParañaqueConnect - Your Account is Ready!"
    )
  end

  # Password reset email for users
  def password_reset(user, reset_token)
    @user = user
    @reset_token = reset_token
    
    mail(
      to: [@user.email],
      subject: "🔒 Reset Your Password - ParañaqueConnect"
    )
  end

  # Confirmation instructions email for users
  def confirmation_instructions(user, confirmation_token)
    @user = user
    @confirmation_token = confirmation_token
    
    mail(
      to: [@user.email],
      subject: "📧 Confirm Your Email - ParañaqueConnect"
    )
  end

  # Devise Integration Methods
  # These methods are called by Devise and use ResendHelper for delivery
  
  def confirmation_instructions(record, token, opts = {})
    # Send confirmation + welcome email for new registrations
    mailer = confirmation_and_welcome(record, token)
    html_content = mailer.body.to_s
    
    ResendHelper.send_email(
      to: record.email,
      subject: "📧 Welcome to ParañaqueConnect - Your Account is Ready!",
      html: html_content
    )
  end

  def reset_password_instructions(record, token, opts = {})
    # Send password reset email
    mailer = password_reset(record, token)
    html_content = mailer.body.to_s
    
    ResendHelper.send_email(
      to: record.email,
      subject: "🔒 Reset Your Password - ParañaqueConnect",
      html: html_content
    )
  end

  def unlock_instructions(record, token, opts = {})
    html_content = render_to_string(
      template: 'devise/mailer/unlock_instructions',
      locals: { 
        @email: record.email,
        @resource: record,
        @token: token
      }
    )
    
    ResendHelper.send_email(
      to: record.email,
      subject: "🔓 Unlock Your Account - ParañaqueConnect",
      html: html_content
    )
  end

  def email_changed(record, opts = {})
    html_content = render_to_string(
      template: 'devise/mailer/email_changed',
      locals: { 
        @email: record.email,
        @resource: record
      }
    )
    
    ResendHelper.send_email(
      to: record.email,
      subject: "📧 Email Address Changed - ParañaqueConnect",
      html: html_content
    )
  end

  def password_change(record, opts = {})
    html_content = render_to_string(
      template: 'devise/mailer/password_change',
      locals: { 
        @email: record.email,
        @resource: record
      }
    )
    
    ResendHelper.send_email(
      to: record.email,
      subject: "🔒 Password Changed - ParañaqueConnect",
      html: html_content
    )
  end

  # Daily summary email for admin (system overview)
  def daily_admin_summary(admin)
    @admin = admin
    @reports_today = Report.where(created_at: 1.day.ago..Time.current)
    @pending_reports = Report.pending.count
    @critical_reports = Report.critical.count
    @barangays_without_captains = Barangay.left_joins(:users).where(users: { role: :barangay_official }).where(users: { id: nil }).count
    
    mail(
      to: [@admin.email],
      subject: "📊 Daily Summary - ParañaqueConnect System Overview"
    )
  end

  # Alert email for admin (urgent issues)
  def admin_alert(admin, alert_type, data = {})
    @admin = admin
    @alert_type = alert_type
    @data = data
    
    case alert_type
    when 'critical_reports'
      @critical_reports = Report.critical.pending
      subject = "🚨 URGENT: #{@critical_reports.count} Critical Reports Need Attention"
    when 'no_captain'
      @barangay = data[:barangay]
      subject = "⚠️ Barangay #{@barangay.name} Needs Captain Assignment"
    when 'system_error'
      @error = data[:error]
      subject = "🔧 System Alert: #{@error}"
    else
      subject = "📢 Admin Alert: #{alert_type.titleize}"
    end
    
    mail(
      to: [@admin.email],
      subject: subject
    )
  end
end
