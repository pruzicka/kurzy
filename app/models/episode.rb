class Episode < ApplicationRecord
  STATUSES = %w[draft published].freeze

  belongs_to :subscription_plan
  belongs_to :video_asset, class_name: "MediaAsset", optional: true
  belongs_to :cover_asset, class_name: "MediaAsset", optional: true
  belongs_to :audio_asset, class_name: "MediaAsset", optional: true

  has_rich_text :content
  has_one_attached :cover_image
  has_one_attached :media
  has_one_attached :video
  has_one_attached :audio
  has_many_attached :attachments

  MAX_COVER_IMAGE_SIZE = 10.megabytes
  ALLOWED_COVER_IMAGE_TYPES = %w[
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp
  ].freeze
  ALLOWED_MEDIA_TYPES = %w[
    audio/mpeg
    audio/mp4
    audio/ogg
    video/mp4
    video/webm
  ].freeze
  MAX_MEDIA_SIZE = 500.megabytes
  ALLOWED_VIDEO_TYPES = %w[video/mp4].freeze
  MAX_VIDEO_SIZE = 5.gigabytes
  ALLOWED_AUDIO_TYPES = %w[audio/mpeg].freeze
  MAX_AUDIO_SIZE = 500.megabytes
  ALLOWED_ATTACHMENT_TYPES = %w[
    application/pdf
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp
  ].freeze
  MAX_ATTACHMENT_SIZE = 10.megabytes

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :position, numericality: { only_integer: true, greater_than: 0 }

  validate :cover_image_must_be_image
  validate :cover_image_must_be_under_size_limit
  validate :media_must_be_valid_type
  validate :media_must_be_under_size_limit
  validate :video_must_be_mp4
  validate :video_must_be_under_size_limit
  validate :audio_must_be_mp3
  validate :audio_must_be_under_size_limit
  validate :attachments_must_be_pdf_or_image
  validate :attachments_must_be_under_size_limit
  validate :video_asset_must_be_video
  validate :cover_asset_must_be_image
  validate :audio_asset_must_be_audio

  before_validation :assign_position, on: :create

  scope :published, -> { where(status: "published") }
  scope :ordered, -> { order(position: :asc) }

  def effective_video_blob
    video_asset&.file&.blob || video&.blob
  end

  def effective_cover_blob
    cover_asset&.file&.blob || cover_image&.blob
  end

  def effective_audio_blob
    audio_asset&.file&.blob || audio&.blob
  end

  def video_attached?
    effective_video_blob.present?
  end

  def audio_attached?
    effective_audio_blob.present?
  end

  def move_up!
    neighbor = subscription_plan.episodes.where("position < ?", position).order(position: :desc).first
    return unless neighbor
    swap_positions!(neighbor)
  end

  def move_down!
    neighbor = subscription_plan.episodes.where("position > ?", position).order(position: :asc).first
    return unless neighbor
    swap_positions!(neighbor)
  end

  private

  def assign_position
    self.position ||= (subscription_plan.episodes.maximum(:position) || 0) + 1
  end

  def swap_positions!(other)
    Episode.transaction do
      current = position
      other_position = other.position

      update_columns(position: 0)
      other.update_columns(position: current)
      update_columns(position: other_position)
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
    return if cover_image.blob.byte_size <= MAX_COVER_IMAGE_SIZE

    errors.add(:cover_image, "maximalne 10 MB")
  end

  def media_must_be_valid_type
    return unless media.attached?
    return unless media.blob
    return if ALLOWED_MEDIA_TYPES.include?(media.blob.content_type)

    errors.add(:media, "pouze audio/video (mp3/mp4/ogg/webm)")
  end

  def media_must_be_under_size_limit
    return unless media.attached?
    return unless media.blob
    return if media.blob.byte_size <= MAX_MEDIA_SIZE

    errors.add(:media, "maximalne 500 MB")
  end

  def video_must_be_mp4
    return unless video.attached?
    return unless video.blob
    return if ALLOWED_VIDEO_TYPES.include?(video.blob.content_type)

    errors.add(:video, "pouze MP4")
  end

  def video_must_be_under_size_limit
    return unless video.attached?
    return unless video.blob
    return if video.blob.byte_size <= MAX_VIDEO_SIZE

    errors.add(:video, "maximalne 5 GB")
  end

  def audio_must_be_mp3
    return unless audio.attached?
    return unless audio.blob
    return if ALLOWED_AUDIO_TYPES.include?(audio.blob.content_type)

    errors.add(:audio, "pouze MP3")
  end

  def audio_must_be_under_size_limit
    return unless audio.attached?
    return unless audio.blob
    return if audio.blob.byte_size <= MAX_AUDIO_SIZE

    errors.add(:audio, "maximalne 500 MB")
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

  def audio_asset_must_be_audio
    return if audio_asset.blank?
    return if audio_asset.audio?

    errors.add(:audio_asset, "musi byt audio")
  end
end
