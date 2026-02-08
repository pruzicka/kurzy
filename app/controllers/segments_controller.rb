class SegmentsController < ApplicationController
  include MandatoryChapterLock

  before_action :require_user!
  before_action :set_course
  before_action :set_chapter
  before_action :set_segment

  def show
    segment_ids = @course.chapters.flat_map { |c| c.segments.map(&:id) }
    @completions_by_segment_id = current_user.segment_completions.where(segment_id: segment_ids).pluck(:segment_id).index_with(true)

    @blocking_chapter = blocking_mandatory_chapter_for(@course, @chapter, @completions_by_segment_id)
    @locked = @blocking_chapter.present?
    @lock_message = @locked ? "Předchozí kapitola (#{@blocking_chapter.title}) není dokončená." : nil

    unless @locked
      # Non-video segments are considered completed once opened (there's nothing to "watch").
      ensure_completion_for_non_video_segment! if !@segment.video.attached?
      update_course_progress!
    end

    @next_segment = next_segment_for(@course, @segment)
    @completions_by_segment_id = current_user.segment_completions.where(segment_id: segment_ids).pluck(:segment_id).index_with(true)
    @segment_completed = @completions_by_segment_id.key?(@segment.id)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_course
    @course = Course.publicly_visible.includes(chapters: :segments).find(params[:course_id])
  end

  def set_chapter
    @chapter = @course.chapters.find(params[:chapter_id])
  end

  def set_segment
    @segment = @chapter.segments.find(params[:id])
  end

  def next_segment_for(course, segment)
    ordered = course.chapters.flat_map(&:segments)
    idx = ordered.index(segment)
    return nil unless idx

    ordered[idx + 1]
  end

  def ensure_completion_for_non_video_segment!
    completion = current_user.segment_completions.find_or_initialize_by(segment: @segment)
    completion.completed_at ||= Time.current
    completion.save! if completion.changed?
  end

  def update_course_progress!
    current_user.course_progresses
                .where(course: @course)
                .first_or_initialize
                .tap { |p| p.last_segment = @segment }
                .save!
  end
end
