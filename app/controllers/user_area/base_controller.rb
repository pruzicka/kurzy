module UserArea
  class BaseController < ApplicationController
    before_action :require_user!

    private

    def require_user!
      redirect_to root_path, alert: "Pro pokracovani se prosim prihlaste." unless user_signed_in?
    end
  end
end
