class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :jwt_authenticatable, 
         omniauth_providers: [:google_oauth2], jwt_revocation_strategy: self
  
  has_many :posts

  # def self.from_google(u)
  #   create_with(uid: u[:uid], full_name: u[:name], provider: u[:provider],
  #               password: Devise.friendly_token[0, 20]).find_or_create_by!(email: u[:email])
  # end

  def self.create_user_for_google(data)                  
    where(uid: data["email"]).first_or_initialize.tap do |user|
      user.provider="google_oauth2"
      user.uid=data["email"]
      user.email=data["email"]
      user.password=Devise.friendly_token[0,20]
      user.password_confirmation=user.password
      user.save!
    end
  end
  
  def jwt_payload
    super
  end
end
