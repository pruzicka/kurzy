class SitemapsController < ApplicationController
  skip_after_action :verify_authorized

  def show
    expires_in 1.hour, public: true

    @courses = Course.publicly_visible.order(updated_at: :desc)

    respond_to do |format|
      format.xml
    end
  end
end
