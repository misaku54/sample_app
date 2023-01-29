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
end