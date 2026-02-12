# frozen_string_literal: true

class ReminderMailer < ActionMailer::Base
  helper :issues
  helper :custom_fields

  def reminder_email
    @issue = params[:issue]
    @recipient = params[:recipient]
    @days_overdue = params[:days_overdue]
    @reminder_type = params[:reminder_type]
    @assignee = params[:assignee]

    subject_text = Setting.plugin_reminder[:email_subject] || '[Redmine] Overdue Issue Reminder'
    subject_text = "#{subject_text} - Eskalasyon" if @reminder_type == :second && @assignee

    @issue_url = "#{Setting.protocol}://#{Setting.host_name}/issues/#{@issue.id}"

    mail(
      from: Setting.mail_from,
      to: @recipient.mail,
      subject: "#{subject_text}: #{@issue.tracker.name} ##{@issue.id} - #{@issue.subject}"
    )
  end
end
