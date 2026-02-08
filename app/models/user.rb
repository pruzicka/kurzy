class User < ApplicationRecord
  has_many :segment_completions, dependent: :destroy
  has_many :course_progresses, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :uid, presence: true

  def self.from_omniauth(auth)
    provider = auth.fetch("provider")
    uid = auth.fetch("uid")
    info = auth.fetch("info", {})

    email = info["email"].to_s
    raise ArgumentError, "OmniAuth did not provide an email" if email.blank?

    where(provider:, uid:).first_or_initialize.tap do |user|
      user.email = email
      user.first_name = info["first_name"]
      user.last_name = info["last_name"]
      user.avatar_url = info["image"]
      user.save!
    end
  end

  def name
    [first_name, last_name].compact.join(" ").presence || email
  end
end
