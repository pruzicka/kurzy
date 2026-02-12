class Author < ApplicationRecord
  has_many :courses
  has_many :subscription_plans

  has_rich_text :bio
  has_one_attached :profile_image

  MAX_PROFILE_IMAGE_SIZE = 10.megabytes
  ALLOWED_PROFILE_IMAGE_TYPES = %w[
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp
  ].freeze

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :slug, presence: true, uniqueness: true

  validate :profile_image_must_be_image
  validate :profile_image_must_be_under_size_limit

  before_validation :generate_slug

  scope :publicly_visible, -> {
    left_joins(:courses, :subscription_plans)
      .where(courses: { status: "public" })
      .or(left_joins(:courses, :subscription_plans).where(subscription_plans: { status: "public" }))
      .distinct
  }

  def name
    "#{first_name} #{last_name}"
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && first_name.present? && last_name.present?
  end

  def profile_image_must_be_image
    return unless profile_image.attached?
    return unless profile_image.blob
    return if ALLOWED_PROFILE_IMAGE_TYPES.include?(profile_image.blob.content_type)

    errors.add(:profile_image, "pouze obrazek (jpg/png/webp/avif/gif)")
  end

  def profile_image_must_be_under_size_limit
    return unless profile_image.attached?
    return unless profile_image.blob
    return if profile_image.blob.byte_size <= MAX_PROFILE_IMAGE_SIZE

    errors.add(:profile_image, "maximalne 10 MB")
  end
end
