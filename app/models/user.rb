class User < ApplicationRecord
  has_one_attached :avatar
  has_many :segment_completions, dependent: :destroy
  has_many :course_progresses, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course

  validates :email, presence: true, uniqueness: true
  validates :username, uniqueness: true, allow_blank: true
  validates :provider, presence: true
  validates :uid, presence: true
  validate :avatar_must_be_image
  validate :avatar_must_be_under_size_limit

  ALLOWED_AVATAR_TYPES = %w[
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp
  ].freeze
  MAX_AVATAR_SIZE = 3.megabytes

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
      user.avatar_url ||= info["image"]
      user.save!
    end
  end

  def name
    [first_name, last_name].compact.join(" ").presence || email
  end

  def cart!
    cart || create_cart!
  end

  private

  def avatar_must_be_image
    return unless avatar.attached?
    return unless avatar.blob
    return if ALLOWED_AVATAR_TYPES.include?(avatar.blob.content_type)

    errors.add(:avatar, "pouze obrazek (jpg/png/webp/avif/gif)")
  end

  def avatar_must_be_under_size_limit
    return unless avatar.attached?
    return unless avatar.blob
    return if avatar.blob.byte_size <= MAX_AVATAR_SIZE

    errors.add(:avatar, "maximalne 3 MB")
  end
end
