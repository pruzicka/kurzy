class CartsController < ApplicationController
  before_action :require_user!

  def show
    @cart = current_user.cart!
    @items = @cart.cart_items.includes(:course)
  end

  def apply_coupon
    cart = current_user.cart!
    if cart.cart_items.empty?
      redirect_to cart_path, alert: "Košík je prázdný."
      return
    end

    cart.apply_coupon!(params[:coupon_code])
    redirect_to cart_path, notice: "Slevový kód byl použit."
  rescue ArgumentError => e
    redirect_to cart_path, alert: e.message
  end

  def remove_coupon
    cart = current_user.cart!
    cart.remove_coupon!
    redirect_to cart_path, notice: "Slevový kód byl odebrán."
  end
end
