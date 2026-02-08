class Segment < ApplicationRecord
  belongs_to :chapter
  belongs_to :video_asset, class_name: "MediaAsset", optional: true
  belongs_to :cover_asset, class_name: "MediaAsset", optional: true
  has_many :segment_completions, dependent: :destroy

  has_rich_text :content
  has_one_attached :video
  has_one_attached :cover_image
  has_many_attached :attachments

  MAX_ATTACHMENT_SIZE = 10.megabytes
  ALLOWED_ATTACHMENT_TYPES = %w[
    application/pdf
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp
  ].freeze
  ALLOWED_COVER_IMAGE_TYPES = %w[
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp
  ].freeze
  ALLOWED_VIDEO_TYPES = %w[
    video/mp4
  ].freeze

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }

  before_validation :assign_position, on: :create

  validate :attachments_must_be_pdf_or_image
  validate :attachments_must_be_under_size_limit
  validate :cover_image_must_be_image
  validate :cover_image_must_be_under_size_limit
  validate :video_must_be_mp4
  validate :video_asset_must_be_video
  validate :cover_asset_must_be_image

  def move_up!
    neighbor = chapter.segments.where("position < ?", position).order(position: :desc).first
    return unless neighbor
    swap_positions!(neighbor)
  end

  def move_down!
    neighbor = chapter.segments.where("position > ?", position).order(position: :asc).first
    return unless neighbor
    swap_positions!(neighbor)
  end

  def effective_video_blob
    video_asset&.file&.blob || video&.blob
  end

  def effective_cover_blob
    cover_asset&.file&.blob || cover_image&.blob
  end

  def video_attached?
    effective_video_blob.present?
  end

  def cover_image_attached?
    effective_cover_blob.present?
  end

  private

  def assign_position
    self.position ||= (chapter.segments.maximum(:position) || 0) + 1
  end

  def swap_positions!(other)
    Segment.transaction do
      current = position
      other_position = other.position

      # Avoid unique index violation on (chapter_id, position) during swap.
      update_columns(position: 0)
      other.update_columns(position: current)
      update_columns(position: other_position)
    end
  end

  def attachments_must_be_pdf_or_image
    attachments.each do |att|
      next unless att.blob
      next if ALLOWED_ATTACHMENT_TYPES.include?(att.blob.content_type)

      errors.add(:attachments, "#{att.filename}: pouze PDF nebo obrazek")
    end
  end

  def attachments_must_be_under_size_limit
    attachments.each do |att|
      next unless att.blob
      next if att.blob.byte_size <= MAX_ATTACHMENT_SIZE

      errors.add(:attachments, "#{att.filename}: maximalne 10 MB na soubor")
    end
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
    return if cover_image.blob.byte_size <= MAX_ATTACHMENT_SIZE

    errors.add(:cover_image, "maximalne 10 MB")
  end

  def video_must_be_mp4
    return unless video.attached?
    return unless video.blob
    return if ALLOWED_VIDEO_TYPES.include?(video.blob.content_type)

    errors.add(:video, "pouze MP4")
  end

  def video_asset_must_be_video
    return if video_asset.blank?
    return if video_asset.video?

    errors.add(:video_asset, "musi byt video")
  end

  def cover_asset_must_be_image
    return if cover_asset.blank?
    return if cover_asset.image?

    errors.add(:cover_asset, "musi byt obrazek")
  end
end
