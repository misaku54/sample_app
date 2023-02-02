class ApplicationMailer < ActionMailer::Base
  # from:送信元のメールアドレス　全体的な設定ができる。
  default from: "ponpon@look.jp"
  layout "mailer"
end
