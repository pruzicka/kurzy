class SegmentsController < ApplicationController
  before_action :require_user!
  before_action :set_course
  before_action :set_chapter
  before_action :set_segment

  def show
  end

  private

  def set_course
    @course = Course.publicly_visible.find(params[:course_id])
  end

  def set_chapter
    @chapter = @course.chapters.find(params[:chapter_id])
  end

  def set_segment
    @segment = @chapter.segments.find(params[:id])
  end
end

