require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  # 検証がパスするかの確認
  test "should be valid" do
    assert @micropost.valid?
  end

  # 検証が失敗するかの確認
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # 空白を入れた場合、検証が失敗するかの確認
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # １４１文字以上を入れた場合、検証が失敗するかの確認
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

end
