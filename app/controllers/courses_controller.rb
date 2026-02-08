class CoursesController < ApplicationController
  before_action :require_user!

  def index
    @courses = Course.publicly_visible.order(created_at: :desc)
  end

  def show
    @course = Course.publicly_visible.includes(chapters: :segments).find(params[:id])
    segment_ids = @course.chapters.flat_map { |c| c.segments.map(&:id) }
    @completions_by_segment_id = current_user.segment_completions.where(segment_id: segment_ids).pluck(:segment_id).index_with(true)

    progress = current_user.course_progresses.find_by(course: @course)
    if progress.present? && params[:start].blank?
      last_segment = @course.chapters.flat_map(&:segments).find { |s| s.id == progress.last_segment_id }
      if last_segment.present?
        redirect_to course_chapter_segment_path(@course, last_segment.chapter, last_segment)
        return
      end
    end
  end
end
