class ApplicationMailer < ActionMailer::Base
  # from:送信先のメールアドレス　全体的な設定ができる。
  default from: "eisei0504@outlook.jp"
  layout "mailer"
end
