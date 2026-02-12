# frozen_string_literal: true

class ReminderMailer < ActionMailer::Base
  helper :issues
  helper :custom_fields
  layout 'mailer'

  def reminder_email
    @issue = params[:issue]
    @recipient = params[:recipient]
    @days_overdue = params[:days_overdue]
    @reminder_type = params[:reminder_type]
    @assignee = params[:assignee]

    subject_text = Setting.plugin_reminder[:email_subject] || '[Redmine] Overdue Issue Reminder'
    subject_text = "#{subject_text} - Escalation" if @reminder_type == :second && @assignee

    mail(to: @recipient.mail, subject: "#{subject_text}: #{@issue.tracker.name} ##{@issue.id} - #{@issue.subject}")
  end
end
