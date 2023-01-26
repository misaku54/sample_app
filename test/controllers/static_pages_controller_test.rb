require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  # 各テストが実行される直前に実行される特別なメソッド
  def setup
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  # test "should get root" do
  #   get root_url
  #   assert_response :success
  #   assert_select "title", "#{@base_title}"
  # end

  test "should get home" do
    get static_pages_home_url
    assert_response :success
    assert_select "title", "#{@base_title}"
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get about" do
    # getするurlはヘルパーメソッドを書く
    get static_pages_about_url
    # サーバーからのｈｔｔｐステータスコードが２００かどうかを調べる。
    assert_response :success
    # 表示されたページの中に特定のhtmlタグがあるかを調べる。
    assert_select "title", "About | #{@base_title}"
  end

  # test "should get contact" do
  #   get static_pages_contact_url
  #   assert_response :success
  #   assert_select "title", "Contact | #{@base_title}"
  # end
end
