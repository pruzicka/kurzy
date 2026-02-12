class Course < ApplicationRecord
  STATUSES = %w[draft public archived].freeze
  COURSE_TYPES = %w[online_course ebook in_person].freeze

  belongs_to :author, optional: true

  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :course_progresses, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :course_tags, dependent: :destroy
  has_many :tags, through: :course_tags

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
  validates :course_type, presence: true, inclusion: { in: COURSE_TYPES }
  validates :currency, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :slug, uniqueness: true, allow_blank: true

  validate :cover_image_must_be_image
  validate :cover_image_must_be_under_size_limit

  scope :publicly_visible, -> { where(status: "public") }

  ZERO_DECIMAL_CURRENCIES = %w[
    BIF CLP DJF GNF JPY KMF KRW MGA PYG RWF UGX VND VUV XAF XOF XPF
  ].freeze

  def price_in_minor_units
    return 0 if price.nil?
    if ZERO_DECIMAL_CURRENCIES.include?(currency.to_s.upcase)
      price
    else
      price * 100
    end
  end

  def currency_precision
    ZERO_DECIMAL_CURRENCIES.include?(currency.to_s.upcase) ? 0 : 2
  end

  def display_precision
    return 0 if currency.to_s.upcase == "CZK"
    currency_precision
  end

  def course_type_label
    case course_type
    when "ebook" then "E-book"
    when "in_person" then "Fyzický trénink"
    else "Online kurz"
    end
  end

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
