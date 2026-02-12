# frozen_string_literal: true

namespace :reminder do
  desc 'Send reminders for overdue issues'
  task send_reminders: :environment do
    puts 'Starting reminder processing...'
    result = Reminder::ReminderService.process
    if result[:success]
      puts 'Completed successfully.'
      puts "Errors: #{result[:errors].join(', ')}" if result[:errors].any?
    else
      puts "Failed: #{result[:errors].join(', ')}"
      exit 1
    end
  end

  desc 'Show overdue issues summary'
  task overdue_summary: :environment do
    settings = Setting.plugin_reminder
    puts "\n=== Overdue Issues Summary ==="
    puts "Enabled: #{settings[:enabled]}"
    puts "First reminder: #{settings[:first_reminder_days]} days"
    puts "Second reminder: #{settings[:second_reminder_days]} days"
    service = Reminder::ReminderService.new
    overdue = service.send(:overdue_issues)
    puts "Found #{overdue.count} overdue issues\n"
  end
end
