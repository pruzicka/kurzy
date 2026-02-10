class SegmentCompletionsController < ApplicationController
  before_action :require_user!
  before_action :set_course
  before_action :set_chapter
  before_action :set_segment

  def create
    authorize @segment, :show?

    completions_by_segment_id = current_user.segment_completions.where(segment_id: @course.chapters.flat_map { |c| c.segments.map(&:id) }).pluck(:segment_id).index_with(true)
    blocking = blocking_mandatory_chapter_for(@course, @chapter, completions_by_segment_id)
    if blocking.present?
      head :forbidden
      return
    end

    completion = current_user.segment_completions.find_or_initialize_by(segment: @segment)
    completion.completed_at ||= Time.current
    completion.save! if completion.changed?

    segment_ids = @course.chapters.flat_map { |c| c.segments.map(&:id) }
    @completions_by_segment_id = current_user.segment_completions.where(segment_id: segment_ids).pluck(:segment_id).index_with(true)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to course_chapter_segment_path(@course, @chapter, @segment) }
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

  def blocking_mandatory_chapter_for(course, current_chapter, completions_by_segment_id)
    previous_chapters = course.chapters.select { |c| c.position < current_chapter.position }
    previous_chapters.sort_by(&:position).reverse_each do |ch|
      next unless ch.is_mandatory?

      segment_ids = ch.segments.map(&:id)
      next if segment_ids.empty?
      next if segment_ids.all? { |id| completions_by_segment_id.key?(id) }

      return ch
    end
    nil
  end
end
