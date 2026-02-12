# frozen_string_literal: true

Redmine::Plugin.register :reminder do
  name 'Reminder Plugin'
  author 'Your Name'
  description 'Sends email reminders for overdue issues based on due date'
  version '1.0.0'
  url 'https://github.com/yourusername/redmine_reminder'
  author_url 'https://github.com/yourusername'

  settings default: {
    'first_reminder_days' => 1,
    'second_reminder_days' => 3,
    'manager_id' => nil,
    'enabled_statuses' => [],
    'email_subject' => '[Redmine] Overdue Issue Reminder',
    'enabled' => true
  }, partial: 'settings/reminder_settings'

  permission :manage_reminders, {}, require: :admin
end

Rails.configuration.to_prepare do
  require_dependency 'reminder/reminder_service'
end
