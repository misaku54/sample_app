class User < ApplicationRecord
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
  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す。クラスメソッド
  def User.digest(string)
    # コストパラメータの設定。高いほど、オリジナルパスワードを計算で推測することが困難
    # テストの場合は、コストを最小にし、本番環境では高いコストで計算する
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    # fixture用のパスワードを生成
    BCrypt::Password.create(string, cost: cost)
  end
end