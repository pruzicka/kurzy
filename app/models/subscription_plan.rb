class SubscriptionPlan < ApplicationRecord
  STATUSES = %w[draft public archived].freeze

  belongs_to :author
  has_many :episodes, -> { order(position: :asc) }, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :order_items, dependent: :destroy

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

  ZERO_DECIMAL_CURRENCIES = Course::ZERO_DECIMAL_CURRENCIES

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :monthly_price, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :currency, presence: true
  validates :annual_discount_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, only_integer: true }

  validate :cover_image_must_be_image
  validate :cover_image_must_be_under_size_limit

  before_validation :generate_slug

  scope :publicly_visible, -> { where(status: "public") }

  def annual_price
    monthly_price * 12 * (100 - annual_discount_percent) / 100
  end

  def monthly_price_in_minor_units
    return 0 if monthly_price.nil?
    if ZERO_DECIMAL_CURRENCIES.include?(currency.to_s.upcase)
      monthly_price
    else
      monthly_price * 100
    end
  end

  def annual_price_in_minor_units
    return 0 if annual_price.nil?
    if ZERO_DECIMAL_CURRENCIES.include?(currency.to_s.upcase)
      annual_price
    else
      annual_price * 100
    end
  end

  def currency_precision
    ZERO_DECIMAL_CURRENCIES.include?(currency.to_s.upcase) ? 0 : 2
  end

  def display_precision
    return 0 if currency.to_s.upcase == "CZK"
    currency_precision
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end

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
