class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      # アカウントが有効でないユーザー(メール認証していない)はログインできないようにする
      if user.activated?
        forwarding_url = session[:forwarding_url] #直前にアクセスしようとしてはじかれたURLを取得しておく。
        reset_session #ログインの直前に必ずこれを書くこと
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user
        redirect_to forwarding_url || user #直前のアクセスURLがあればそこにリダイレクトなければ、プロフィールへリダイレクト
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # エラーメッセージを作成する。
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
