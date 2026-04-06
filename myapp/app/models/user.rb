class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # 既存のバリデーションなどはそのまま

  has_many :training_logs
  
  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      # user.name = "ゲストユーザー"
      # 他に必須項目（年齢や目標など）があれば初期値を設定
    end
  end
end