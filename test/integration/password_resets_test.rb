require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest
  # 送信したメールをリセットする。
  # ActionMailer::Base.deliveries.clearを忘れると別のテストで送ったメールが残る
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets
  # メール認証フォームへアクセスできるかの確認
  test "password reset path" do
    # メール認証フォームへ
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  # 誤ったメールを送信した時に、検証が反応するかの確認。
  test "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets

  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm
  # メール認証フォームで送信後、ダイジェストが設定されており、メールが送信されていることの確認
  test "reset with valid email" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  # メール認証フォームで空白のメールアドレスを送信した場合、ルートへ遷移しているかの確認
  test "reset with wrong email" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  # 有効ではないユーザーのURLでリンクをクリックした場合、ルートへ遷移しているかの確認
  test "reset with inactive user" do
    # モデル.toggle(属性) 属性に反対のブール値を割り当てる
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  # リンクのトークンが誤っている場合、ルートへ遷移しているかの確認
  test "reset with right email but wrong token" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  # 正しいリンクをクリックした際に、編集画面へ遷移しているか。隠しパラメータにメールアドレスが設定されているかの確認
  test "reset with right email and right token" do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm
  # パスワード再設定で不一致した際に、エラーメッセージが表示されているかの確認
  test "update with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  # パスワード再設定でパスワードを空白で設定した場合、エラーメッセージが表示されているかの確認
  test "update with empty password" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  # パスワード再設定で正しいパスワードで設定した場合、ログインし、プロフィール画面へ遷移してるかの確認
  test "update with valid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
    assert_nil @reset_user.reload.reset_digest
  end
end

class ExpiredToken < PasswordResets

  def setup
    super
    # パスワードリセットのトークンを作成する
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # トークンを手動で失効させる
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # ユーザーのパスワードの更新を試みる
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
  end
end

class ExpiredTokenTest < ExpiredToken

  test "should redirect to the password-reset page" do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password-reset page" do
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
