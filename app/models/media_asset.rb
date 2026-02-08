class MediaAsset < ApplicationRecord
  has_one_attached :file

  has_many :video_segments, class_name: "Segment", foreign_key: :video_asset_id, inverse_of: :video_asset, dependent: :nullify
  has_many :cover_segments, class_name: "Segment", foreign_key: :cover_asset_id, inverse_of: :cover_asset, dependent: :nullify

  MEDIA_TYPES = %w[video image].freeze
  ALLOWED_IMAGE_TYPES = Segment::ALLOWED_COVER_IMAGE_TYPES
  ALLOWED_VIDEO_TYPES = Segment::ALLOWED_VIDEO_TYPES
  MAX_IMAGE_SIZE = Segment::MAX_ATTACHMENT_SIZE

  validates :title, presence: true
  validates :media_type, inclusion: { in: MEDIA_TYPES }
  validate :file_presence
  validate :file_type_is_allowed
  validate :image_size_under_limit

  before_validation :infer_media_type, if: -> { media_type.blank? && file.attached? }

  def usage_count
    video_segments.size + cover_segments.size
  end

  def usage_segments
    (video_segments.to_a + cover_segments.to_a).uniq
  end

  def video?
    media_type == "video"
  end

  def image?
    media_type == "image"
  end

  private

  def infer_media_type
    return unless file.blob
    content_type = file.blob.content_type.to_s
    self.media_type =
      if content_type.start_with?("image/")
        "image"
      else
        "video"
      end
  end

  def file_presence
    errors.add(:file, "musí být vybrán") unless file.attached?
  end

  def file_type_is_allowed
    return unless file.attached?
    return unless file.blob

    content_type = file.blob.content_type
    if image?
      errors.add(:file, "pouze obrazek (jpg/png/webp/avif/gif)") unless ALLOWED_IMAGE_TYPES.include?(content_type)
    elsif video?
      errors.add(:file, "pouze MP4") unless ALLOWED_VIDEO_TYPES.include?(content_type)
    else
      errors.add(:file, "neplatný typ média")
    end
  end

  def image_size_under_limit
    return unless file.attached?
    return unless file.blob
    return unless image?

    if file.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:file, "maximalne 10 MB")
    end
  end
end
