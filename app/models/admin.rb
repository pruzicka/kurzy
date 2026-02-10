class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:login]

  validates :username, presence: true, uniqueness: true

  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)&.downcase
    if login.present?
      where("LOWER(username) = :login OR LOWER(email) = :login", login: login).first
    else
      where(conditions.to_h).first
    end
  end
end
