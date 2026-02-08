class Segment < ApplicationRecord
  belongs_to :chapter

  has_rich_text :content
  has_one_attached :video
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

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }

  before_validation :assign_position, on: :create

  validate :attachments_must_be_pdf_or_image
  validate :attachments_must_be_under_size_limit

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
end
