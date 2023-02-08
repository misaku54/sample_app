class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    # indexアクションでUsersをページネートする
    @users = User.all.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    # @micropostsインスタンス変数をshowアクションに追加する
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    # ユーザー登録中にログインする。
    @user = User.new(user_params)
    if @user.save
      # reset_session
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user
      @user.send_activation_email
      # ユーザー登録時に登録されたメールアドレスにアカウント有効化のリンクを貼ったメールを送る。
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # 更新に成功した場合を扱う
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_path, status: :see_other
  end

  # get /users/:id/following
  # 同じインスタンス変数、異なるデータセットを使い、ふたつのページを一つのテンプレートで表示させる。
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow' , status: :unprocessable_entity
  end

  # get /users/:id/followers
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow' , status: :unprocessable_entity
  end

  private
    # ストロングパラメータ
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # beforeフィルタ

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # ログインユーザの権限が管理者でない場合、ルートへリダイレクトする
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
