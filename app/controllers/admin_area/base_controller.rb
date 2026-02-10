module AdminArea
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    layout "admin"

    private

    def pundit_user
      current_admin
    end
  end
end
