class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # redirect_to user
    respond_to do |format|
      # リクエストフォーマットによって振る舞いをかえる。同期通信か非同期か
      format.html { redirect_to @user }
      # 特定のJavaScriptを実行する。指定がないときはapp/views/relationships/create.js.erb
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    # redirect_to user, status: :see_other
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
