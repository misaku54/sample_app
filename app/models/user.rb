class User < ApplicationRecord
  # 外部キーはデフォルトで<class>_idを検索しようとする。
  # class_nameは探索するモデル名を指定できる。foreign_keyは探索に使う外部キーを指定できる。
  # オプションを設定せず、デフォルトのままだとactive_relationshipモデルのuser_idを検索しようとする。
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower


  # 記憶トークンに対応する仮属性を用意する。
  attr_accessor :remember_token, :activation_token, :reset_token

  # コールバック
  before_save   :downcase_email
  before_create :create_activation_digest

  # ヴァリデーション
  validates :name,  presence: true, length: { maximum:50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true #登録されるメールアドレスが小文字で統一されていれば、大文字小文字を区別しない設定はいらない

  # セキュアなパスワードの実装
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す。クラスメソッド
  def self.digest(string)
    # コストパラメータの設定。高いほど、オリジナルパスワードを計算で推測することが困難
    # テストの場合は、コストを最小にし、本番環境では高いコストで計算する
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    # fixture用のパスワードを生成
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token #記憶トークンを作成
    update_attribute(:remember_digest, User.digest(remember_token)) #記憶ダイジェストを更新　なんでここはselfいらないの？
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #　パスワード再設定用の属性を設置する。
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
    # update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # パスワード再設定メールの送信時刻が、現在時刻より2時間以上前（早い）の場合
    reset_sent_at < 2.hour.ago
  end

  # ログインしているユーザーのマイクロポストをすべて取得
  def feed
    Micropost.where("user_id = ?", id)
  end

  # ユーザーをフォローする。
  def follow(other_user)
    # フォローしているユーザーオブジェクト群に引数で渡したユーザーオブジェクトを追加する。
    # 注意点　followingで作成したオブジェクト群は配列オブジェクトではない。
    following << other_user  unless self == other_user
  end

  # ユーザーをフォロー解除する。
  def unfollow(other_user)
    # フォローしているユーザーの中から引数で渡されたユーザーオブジェクトを見つけて削除する。
    following.delete(other_user)
  end

  # 引数で渡されたユーザーをフォローしているか？true falseを返す。
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token   = User.new_token
      self.activation_digest  = User.digest(activation_token)
    end
end