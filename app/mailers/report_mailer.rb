class ReportMailer < Devise::Mailer
  # Email sent to admin when a new report is created (for quality control)
  def admin_new_report_notification(report)
    @report = report

    # Find all admin users
    @admins = User.where(role: :admin)

    # Only send if there are admins
    return unless @admins.any?

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/admin_new_report_notification",
      layout: "mailer",
      locals: {
        report: @report,
        admins: @admins
      }
    )

    # Send to all admins
    admin_emails = @admins.pluck(:email)
    ResendHelper.send_email(
      to: admin_emails,
      subject: "New Report Submitted: #{@report.title} - #{@report.barangay.name}",
      html: html_content
    )
  end

  # Email sent to report creator when report is approved
  def report_approved_notification(report)
    @report = report

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/report_approved_notification",
      layout: "mailer",
      locals: {
        report: @report
      }
    )

    ResendHelper.send_email(
      to: @report.user.email,
      subject: "Report Approved: #{@report.title} - #{@report.barangay.name}",
      html: html_content
    )
  end

  # Email sent to report creator when report is rejected
  def report_rejected_notification(report)
    @report = report

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/report_rejected_notification",
      layout: "mailer",
      locals: {
        report: @report
      }
    )

    ResendHelper.send_email(
      to: @report.user.email,
      subject: "Report Update: #{@report.title} - #{@report.barangay.name}",
      html: html_content
    )
  end

  # Email sent to admins when a resident requests to reopen a closed report
  def reopen_request_notification(report)
    @report = report

    # Find all admin users
    @admins = User.where(role: :admin)

    # Only send if there are admins
    return unless @admins.any?

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/reopen_request_notification",
      layout: "mailer",
      locals: {
        report: @report,
        admins: @admins
      }
    )

    # Send to all admins
    admin_emails = @admins.pluck(:email)
    ResendHelper.send_email(
      to: admin_emails,
      subject: "Reopen Request: #{@report.title} - #{@report.barangay.name}",
      html: html_content
    )
  end

  # Email sent to report creator when their reopen request is approved
  def reopen_approved_notification(report)
    @report = report

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/reopen_approved_notification",
      layout: "mailer",
      locals: {
        report: @report
      }
    )

    ResendHelper.send_email(
      to: @report.user.email,
      subject: "Report Reopened: #{@report.title} - #{@report.barangay.name}",
      html: html_content
    )
  end

  # Email sent to barangay captain when a new report is created (after admin approval)
  def new_report_notification(report)
    @report = report

    # Only send email if report has a barangay and that barangay has a captain
    return unless @report.barangay.present?

    @barangay_captain = @report.barangay.users.find_by(role: :barangay_official)

    # Only send email if there's a captain for this barangay
    return unless @barangay_captain.present?

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/new_report_notification",
      layout: "mailer",
      locals: {
        report: @report,
        barangay_captain: @barangay_captain
      }
    )

    ResendHelper.send_email(
      to: @barangay_captain.email,
      subject: "New Report: #{@report.title} - #{@report.barangay.name}",
      html: html_content
    )
  end

  # Email sent to report creator when status changes
  def status_change_notification(report, old_status)
    @report = report
    @old_status = old_status
    @new_status = report.status

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/status_change_notification",
      layout: "mailer",
      locals: {
        report: @report,
        old_status: @old_status,
        new_status: @new_status
      }
    )

    ResendHelper.send_email(
      to: @report.user.email,
      subject: "Report Update: #{@report.title} - Status Changed to #{@new_status.titleize}",
      html: html_content
    )
  end

  # Email sent to report creator when a new comment is added
  def new_comment_notification(report, comment)
    @report = report
    @comment = comment
    @commenter = comment.user

    # Don't notify the report creator if they commented on their own report
    return if @commenter == @report.user

    # Don't notify if an official/admin commented (they have status change emails)
    return if @commenter.barangay_official? || @commenter.admin?

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/new_comment_notification",
      layout: "mailer",
      locals: {
        report: @report,
        comment: @comment,
        commenter: @commenter
      }
    )

    ResendHelper.send_email(
      to: @report.user.email,
      subject: "New Comment on Your Report: #{@report.title}",
      html: html_content
    )
  end

  # Welcome email for new barangay captain accounts
  def welcome_captain(captain)
    @captain = captain
    @barangay = captain.barangay

    # Only send email if captain has a barangay assigned
    return unless @barangay.present?

    # Generate password reset token so captain can change password directly from email
    # We use send_reset_password_instructions which generates the token but don't send the default email
    @reset_token = @captain.send(:set_reset_password_token)

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/welcome_captain",
      layout: "mailer",
      locals: {
        captain: @captain,
        barangay: @barangay,
        reset_token: @reset_token
      }
    )

    ResendHelper.send_email(
      to: @captain.email,
      subject: "Welcome to ParañaqueConnect - Barangay Captain Account",
      html: html_content
    )
  end

  # Welcome email for new resident registration (with confirmation)
  def welcome_resident(resident)
    @resident = resident

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/welcome_resident",
      layout: "mailer",
      locals: {
        resident: @resident
      }
    )

    ResendHelper.send_email(
      to: @resident.email,
      subject: "Welcome to ParañaqueConnect - Your Account is Ready!",
      html: html_content
    )
  end

  # Confirmation + Welcome email for new resident registration
  def confirmation_and_welcome(resident, confirmation_token)
    @resident = resident
    @confirmation_token = confirmation_token

    mail(
      to: [ @resident.email ],
      subject: "Welcome to ParañaqueConnect - Your Account is Ready!"
    )
  end

  # Password reset email for users
  def password_reset(user, reset_token)
    @user = user
    @reset_token = reset_token

    mail(
      to: [ @user.email ],
      subject: "Reset Your Password - ParañaqueConnect"
    )
  end

  # Confirmation instructions email for users
  def confirmation_instructions(user, confirmation_token)
    @user = user
    @confirmation_token = confirmation_token

    mail(
      to: [ @user.email ],
      subject: "Confirm Your Email - ParañaqueConnect"
    )
  end

  # Devise Integration Methods
  # These methods are called by Devise and use ResendHelper for delivery

  def confirmation_instructions(record, token, opts = {})
    # Send confirmation + welcome email for new registrations
    @user = record
    @confirmation_token = token

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/confirmation_instructions",
      layout: "mailer",
      locals: {
        user: @user,
        confirmation_token: @confirmation_token
      }
    )

    ResendHelper.send_email(
      to: record.email,
      subject: "📧 Welcome to ParañaqueConnect - Your Account is Ready!",
      html: html_content
    )
  end

  def reset_password_instructions(record, token, opts = {})
    # Send password reset email
    @user = record
    @reset_token = token

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/password_reset",
      layout: "mailer",
      locals: {
        user: @user,
        reset_token: @reset_token
      }
    )

    ResendHelper.send_email(
      to: record.email,
      subject: "Reset Your Password - ParañaqueConnect",
      html: html_content
    )
  end

  def unlock_instructions(record, token, opts = {})
    html_content = render_to_string(
      template: "devise/mailer/unlock_instructions",
      layout: "mailer",
      locals: {
        email: record.email,
        resource: record,
        token: token
      }
    )

    ResendHelper.send_email(
      to: record.email,
      subject: "Unlock Your Account - ParañaqueConnect",
      html: html_content
    )
  end

  def email_changed(record, opts = {})
    html_content = render_to_string(
      template: "devise/mailer/email_changed",
      layout: "mailer",
      locals: {
        email: record.email,
        resource: record
      }
    )

    ResendHelper.send_email(
      to: record.email,
      subject: "Email Address Changed - ParañaqueConnect",
      html: html_content
    )
  end

  def password_change(record, opts = {})
    html_content = render_to_string(
      template: "devise/mailer/password_change",
      layout: "mailer",
      locals: {
        email: record.email,
        resource: record
      }
    )

    ResendHelper.send_email(
      to: record.email,
      subject: "Password Changed - ParañaqueConnect",
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

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/daily_admin_summary",
      layout: "mailer",
      locals: {
        admin: @admin,
        reports_today: @reports_today,
        pending_reports: @pending_reports,
        critical_reports: @critical_reports,
        barangays_without_captains: @barangays_without_captains
      }
    )

    ResendHelper.send_email(
      to: @admin.email,
      subject: "Daily Summary - ParañaqueConnect System Overview",
      html: html_content
    )
  end

  # Alert email for admin (urgent issues)
  def admin_alert(admin, alert_type, data = {})
    @admin = admin
    @alert_type = alert_type
    @data = data

    case alert_type
    when "critical_reports"
      @critical_reports = Report.critical.pending
      subject = "URGENT: #{@critical_reports.count} Critical Reports Need Attention"
    when "no_captain"
      @barangay = data[:barangay]
      subject = "Barangay #{@barangay.name} Needs Captain Assignment"
    when "system_error"
      @error = data[:error]
      subject = "System Alert: #{@error}"
    else
      subject = "Admin Alert: #{alert_type.titleize}"
    end

    # Render the email template with the mailer layout to preserve CSS styling
    html_content = render_to_string(
      template: "report_mailer/admin_alert",
      layout: "mailer",
      locals: {
        admin: @admin,
        alert_type: @alert_type,
        data: @data,
        critical_reports: @critical_reports,
        barangay: @barangay,
        error: @error
      }
    )

    ResendHelper.send_email(
      to: @admin.email,
      subject: subject,
      html: html_content
    )
  end
end
