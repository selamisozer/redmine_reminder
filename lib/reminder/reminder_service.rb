# frozen_string_literal: true

module Reminder
  class ReminderService
    attr_reader :errors

    def initialize
      @errors = []
    end

    def process_reminders
      return unless settings[:enabled].to_s == 'true' || settings[:enabled] == true

      Rails.logger.info '[ReminderPlugin] Starting reminder processing...'

      first_reminder_days = settings[:first_reminder_days].to_i
      second_reminder_days = settings[:second_reminder_days].to_i
      manager = find_manager

      overdue_issues.each do |issue|
        days_overdue = calculate_days_overdue(issue)

        if days_overdue >= first_reminder_days && days_overdue < second_reminder_days
          send_first_reminder(issue, days_overdue)
        elsif days_overdue >= second_reminder_days && manager
          send_second_reminder(issue, days_overdue, manager)
        end
      end

      Rails.logger.info '[ReminderPlugin] Reminder processing completed.'
      { success: true, errors: @errors }
    rescue StandardError => e
      Rails.logger.error "[ReminderPlugin] Error: #{e.message}"
      @errors << e.message
      { success: false, errors: @errors }
    end

    private

    def settings
      Setting.plugin_reminder
    end

    def find_manager
      manager_id = settings[:manager_id]
      return nil if manager_id.blank?
      User.find_by(id: manager_id)
    end

    def overdue_issues
      enabled_status_ids = settings[:enabled_statuses]
      enabled_status_ids = Array(enabled_status_ids).map(&:to_i).reject(&:zero?)

      scope = Issue.where.not(due_date: nil).where('due_date < ?', Date.today)
      scope = scope.where(status_id: enabled_status_ids) if enabled_status_ids.any?
      scope = scope.where.not(assigned_to_id: nil)
      scope.includes(:assigned_to, :project, :status, :tracker, :author)
    end

    def calculate_days_overdue(issue)
      return 0 if issue.due_date.nil?
      (Date.today - issue.due_date).to_i
    end

    def send_first_reminder(issue, days_overdue)
      return unless issue.assigned_to
      Rails.logger.info "[ReminderPlugin] Sending first reminder for Issue ##{issue.id}"
      ReminderMailer.with(issue: issue, recipient: issue.assigned_to, days_overdue: days_overdue, reminder_type: :first).reminder_email.deliver_now
    rescue StandardError => e
      @errors << "Issue ##{issue.id}: #{e.message}"
    end

    def send_second_reminder(issue, days_overdue, manager)
      return unless manager
      Rails.logger.info "[ReminderPlugin] Sending second reminder for Issue ##{issue.id} to manager"
      ReminderMailer.with(issue: issue, recipient: manager, days_overdue: days_overdue, reminder_type: :second, assignee: issue.assigned_to).reminder_email.deliver_now
    rescue StandardError => e
      @errors << "Issue ##{issue.id}: #{e.message}"
    end

    def self.process
      new.process_reminders
    end
  end
end
