class MediaAsset < ApplicationRecord
  has_one_attached :file

  has_many :video_segments, class_name: "Segment", foreign_key: :video_asset_id, inverse_of: :video_asset, dependent: :nullify
  has_many :cover_segments, class_name: "Segment", foreign_key: :cover_asset_id, inverse_of: :cover_asset, dependent: :nullify
  has_many :audio_segments, class_name: "Segment", foreign_key: :audio_asset_id, inverse_of: :audio_asset, dependent: :nullify
  has_many :video_episodes, class_name: "Episode", foreign_key: :video_asset_id, inverse_of: :video_asset, dependent: :nullify
  has_many :cover_episodes, class_name: "Episode", foreign_key: :cover_asset_id, inverse_of: :cover_asset, dependent: :nullify
  has_many :audio_episodes, class_name: "Episode", foreign_key: :audio_asset_id, inverse_of: :audio_asset, dependent: :nullify

  MEDIA_TYPES = %w[video image audio].freeze
  ALLOWED_IMAGE_TYPES = Segment::ALLOWED_COVER_IMAGE_TYPES
  ALLOWED_VIDEO_TYPES = Segment::ALLOWED_VIDEO_TYPES
  ALLOWED_AUDIO_TYPES = %w[audio/mpeg].freeze
  MAX_IMAGE_SIZE = Segment::MAX_ATTACHMENT_SIZE
  MAX_AUDIO_SIZE = 500.megabytes

  validates :title, presence: true
  validates :media_type, inclusion: { in: MEDIA_TYPES }
  validate :file_presence
  validate :file_type_is_allowed
  validate :image_size_under_limit

  before_validation :infer_media_type, if: -> { media_type.blank? && file.attached? }
  before_destroy :detach_from_segments
  before_destroy :purge_file

  def usage_count
    video_segments.size + cover_segments.size + audio_segments.size + video_episodes.size + cover_episodes.size + audio_episodes.size
  end

  def usage_segments
    (video_segments.to_a + cover_segments.to_a + audio_segments.to_a).uniq
  end

  def usage_episodes
    (video_episodes.to_a + cover_episodes.to_a + audio_episodes.to_a).uniq
  end

  def video?
    media_type == "video"
  end

  def image?
    media_type == "image"
  end

  def audio?
    media_type == "audio"
  end

  private

  def infer_media_type
    return unless file.blob
    content_type = file.blob.content_type.to_s
    self.media_type =
      if content_type.start_with?("image/")
        "image"
      elsif content_type.start_with?("audio/")
        "audio"
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
    elsif audio?
      errors.add(:file, "pouze MP3") unless ALLOWED_AUDIO_TYPES.include?(content_type)
    else
      errors.add(:file, "neplatný typ média")
    end
  end

  def image_size_under_limit
    return unless file.attached?
    return unless file.blob

    if image? && file.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:file, "maximalne 10 MB")
    elsif audio? && file.blob.byte_size > MAX_AUDIO_SIZE
      errors.add(:file, "maximalne 500 MB")
    end
  end

  def detach_from_segments
    Segment.where(video_asset_id: id).update_all(video_asset_id: nil)
    Segment.where(cover_asset_id: id).update_all(cover_asset_id: nil)
    Segment.where(audio_asset_id: id).update_all(audio_asset_id: nil)
    Episode.where(video_asset_id: id).update_all(video_asset_id: nil)
    Episode.where(cover_asset_id: id).update_all(cover_asset_id: nil)
    Episode.where(audio_asset_id: id).update_all(audio_asset_id: nil)
  end

  def purge_file
    file.purge if file.attached?
  end
end
