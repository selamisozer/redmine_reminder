# frozen_string_literal: true

class ReminderTestController < ApplicationController
  before_action :require_admin

  def send_test
    test_issue = Issue.where.not(due_date: nil).where('due_date < ?', Date.today).where.not(assigned_to_id: nil).first

    if test_issue
      ReminderMailer.with(issue: test_issue, recipient: User.current, days_overdue: 1, reminder_type: :first).reminder_email.deliver_now
      flash[:notice] = l(:notice_test_reminder_sent)
    else
      flash[:error] = 'No overdue issues found for testing.'
    end
    redirect_to settings_path(plugin: 'reminder')
  rescue StandardError => e
    flash[:error] = "Error: #{e.message}"
    redirect_to settings_path(plugin: 'reminder')
  end
end
