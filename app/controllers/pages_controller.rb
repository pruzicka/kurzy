class PagesController < ApplicationController
  skip_after_action :verify_authorized

  # Public pages; keep them accessible even when the app is otherwise "private".

  def disclaimer
  end

  def terms
  end

  def privacy
  end

  def data_deletion
  end
end
