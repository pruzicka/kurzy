class Course < ApplicationRecord
  STATUSES = %w[draft public archived].freeze

  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :course_progresses, dependent: :destroy

  has_rich_text :description
  has_one_attached :cover_image

  MAX_COVER_IMAGE_SIZE = 10.megabytes
  ALLOWED_COVER_IMAGE_TYPES = %w[
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp
  ].freeze

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :currency, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :slug, uniqueness: true, allow_blank: true

  validate :cover_image_must_be_image
  validate :cover_image_must_be_under_size_limit

  scope :publicly_visible, -> { where(status: "public") }

  private

  def cover_image_must_be_image
    return unless cover_image.attached?
    return unless cover_image.blob
    return if ALLOWED_COVER_IMAGE_TYPES.include?(cover_image.blob.content_type)

    errors.add(:cover_image, "pouze obrazek (jpg/png/webp/avif/gif)")
  end

  def cover_image_must_be_under_size_limit
    return unless cover_image.attached?
    return unless cover_image.blob
    return if cover_image.blob.byte_size <= MAX_COVER_IMAGE_SIZE

    errors.add(:cover_image, "maximalne 10 MB")
  end
end
