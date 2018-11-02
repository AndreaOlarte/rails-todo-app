class WeeklyReminderWorker
  include Sidekiq::Worker

  def perform(*args)
    User.all.each do |user|
      unless(user.lists.length == 0)
        TodoMailer.weekly_reminder(user).deliver_now  
      end
    end
  end
end
