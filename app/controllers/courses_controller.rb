class CoursesController < ApplicationController
  def index
    @courses = Course.publicly_visible.order(created_at: :desc)
  end

  def show
    @course = Course.publicly_visible.find(params[:id])
  end
end

