class CartsController < ApplicationController
  before_action :require_user!

  def show
    @cart = current_user.cart!
    @items = @cart.cart_items.includes(:course)
  end
end

