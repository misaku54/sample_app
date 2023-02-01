class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    # to-送信先　subject-件名
    mail to: user.email, subject: "Account activation"
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
