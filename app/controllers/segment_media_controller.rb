class SegmentMediaController < ApplicationController
  include MandatoryChapterLock

  before_action :require_user!
  before_action :set_course
  before_action :set_chapter
  before_action :set_segment
  before_action :ensure_unlocked!

  def video
    return head :not_found unless @segment.video.attached?
    redirect_to_service_url(@segment.video.blob, disposition: "inline")
  end

  def cover_image
    return head :not_found unless @segment.cover_image.attached?
    redirect_to_service_url(@segment.cover_image.blob, disposition: "inline")
  end

  def attachment
    attachment = @segment.attachments.attachments.find_by(id: params[:attachment_id])
    return head :not_found unless attachment

    redirect_to_service_url(attachment.blob, disposition: "inline")
  end

  private

  def set_course
    @course = Course.publicly_visible.includes(chapters: :segments).find(params[:course_id])
  end

  def set_chapter
    @chapter = @course.chapters.find(params[:chapter_id])
  end

  def set_segment
    @segment = @chapter.segments.find(params[:segment_id] || params[:id])
  end

  def ensure_unlocked!
    segment_ids = @course.chapters.flat_map { |c| c.segments.map(&:id) }
    completions_by_segment_id = current_user.segment_completions.where(segment_id: segment_ids).pluck(:segment_id).index_with(true)

    blocking = blocking_mandatory_chapter_for(@course, @chapter, completions_by_segment_id)
    head :forbidden if blocking.present?
  end

  def redirect_to_service_url(blob, disposition:)
    response.headers["Cache-Control"] = "no-store"

    url = blob.url(
      # Needs to be long enough for a typical viewing session (range requests can happen later).
      expires_in: 1.hour,
      disposition: disposition,
      filename: blob.filename,
      content_type: blob.content_type
    )

    redirect_to url, allow_other_host: true
  end
end
