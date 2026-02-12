class AuthorsController < ApplicationController
  skip_after_action :verify_authorized

  def index
    @authors = Author.publicly_visible.order(:last_name, :first_name)
  end

  def show
    @author = Author.find_by!(slug: params[:slug])
    @courses = @author.courses.publicly_visible.order(created_at: :desc)
    @subscription_plans = @author.subscription_plans.where(status: "public").order(created_at: :desc)
  end
end
