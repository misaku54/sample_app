require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    # Userオブジェクトを作成　インスタンス変数に格納することですべてのテスト内で使える
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  test "should be valid" do
    assert @user.valid?
  end
end
