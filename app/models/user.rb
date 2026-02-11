class User < ApplicationRecord
  has_one_attached :avatar
  has_many :segment_completions, dependent: :destroy
  has_many :course_progresses, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :oauth_identities, dependent: :destroy
  has_many :user_sessions, dependent: :destroy

  MAX_CONCURRENT_SESSIONS = 2

  validates :email, presence: true, uniqueness: true
  validates :username, uniqueness: true, allow_blank: true
  validates :billing_ico, ico: true, allow_blank: true
  validates :billing_dic, dic: true, allow_blank: true
  validate :billing_address_required_with_company_details
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

    # 1. Find by OauthIdentity
    identity = OauthIdentity.find_by(provider: provider, uid: uid)
    return update_from_omniauth!(identity.user, info) if identity

    # 2. Find by email — link to existing user
    user = User.find_by(email: email)
    if user
      user.oauth_identities.create!(provider: provider, uid: uid, email: email, info: info.to_h)
      return update_from_omniauth!(user, info)
    end

    # 3. Create new user + identity
    user = User.create!(
      email: email,
      first_name: info["first_name"],
      last_name: info["last_name"],
      avatar_url: info["image"]
    )
    user.oauth_identities.create!(provider: provider, uid: uid, email: email, info: info.to_h)
    user
  end

  def name
    [first_name, last_name].compact.join(" ").presence || email
  end

  def cart!
    cart || create_cart!
  end

  def find_or_create_stripe_customer!
    return stripe_customer_id if stripe_customer_id.present?

    customer = Stripe::Customer.create(
      email: email,
      name: name,
      metadata: { user_id: id }
    )
    update!(stripe_customer_id: customer.id)
    customer.id
  end

  def billing_info_present?
    billing_name.present? && billing_street.present? && billing_city.present? && billing_zip.present?
  end

  def enforce_session_limit!
    excess = user_sessions.order(created_at: :desc).offset(MAX_CONCURRENT_SESSIONS)
    excess.destroy_all
  end

  private

  def self.update_from_omniauth!(user, info)
    user.first_name = info["first_name"] if info["first_name"].present?
    user.last_name = info["last_name"] if info["last_name"].present?
    user.avatar_url ||= info["image"]
    user.save! if user.changed?
    user
  end

  def billing_address_required_with_company_details
    return unless billing_ico.present? || billing_dic.present?

    errors.add(:billing_name, "je povinné pro firemní fakturu") if billing_name.blank?
    errors.add(:billing_street, "je povinné pro firemní fakturu") if billing_street.blank?
    errors.add(:billing_city, "je povinné pro firemní fakturu") if billing_city.blank?
    errors.add(:billing_zip, "je povinné pro firemní fakturu") if billing_zip.blank?
  end

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
