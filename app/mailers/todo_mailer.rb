class TodoMailer < ApplicationMailer
  def weekly_reminder(user)
    @user = user
    mail(to: @user.email, subject: 'TODO App - Weekly Reminder')
  end
end
