class HomeController < ApplicationController
  def index
    @courses = Course.publicly_visible.order(created_at: :desc)
  end
end

