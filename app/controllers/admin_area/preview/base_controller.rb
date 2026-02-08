module AdminArea
  module Preview
    class BaseController < ApplicationController
      before_action :authenticate_admin!

      layout "application"

      before_action do
        # Used by PreviewPathsHelper to switch internal links to /admin/preview/...
        @admin_preview = true
      end
    end
  end
end

