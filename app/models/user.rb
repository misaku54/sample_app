class User < ApplicationRecord
  # 記憶トークンに対応する仮属性を用意する。
  attr_accessor :remember_token

  # コールバック
  before_save { email.downcase! }

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
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end